From: Ben Greear <greearb@candelatech.com>
Subject: Re: netif_rx packet dumping
Date: Tue, 08 Mar 2005 10:27:17 -0800
Message-ID: <422DEE85.5010302@candelatech.com>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	<42278122.6000000@ev-en.org>	<20050303133659.0d224e61.davem@davemloft.net>	<42278554.2090902@ev-en.org>	<20050303135718.2e1a0170.davem@davemloft.net>	<422DC7CE.2040800@ev-en.org>	<m1y8cykr7i.fsf@muc.de> <20050308100902.24b67b2f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, baruch@ev-en.org, shemminger@osdl.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050308100902.24b67b2f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 08 Mar 2005 18:00:49 +0100
> Andi Kleen <ak@muc.de> wrote:
> 
> 
>>Baruch Even <baruch@ev-en.org> writes:
>>
>>>I can squeeze the tcp_skb_cb to one pointer at the expense of extra
>>>work to remove a packet from the list (the other pointer is the prev
>>>pointer).
>>
>>You could also use a xor list in theory. But I'm not sure it's worth it.
>>Increasing cb by 4 bytes shouldn't be a very big issue.
> 
> 
> Going from "40" to "44" takes 64-bit platforms onto another cache line
> for struct sk_buff, as I stated in another email.

Seems like we might could squish the sk_buff a bit:

Do we really need 32-bits for the mac-len:

	unsigned int		len,
				data_len,
				mac_len,
				csum;

Some of these flags could be collapsed into a single field and we
could do bit-shift operations for the single flags we care about.
This would also make it easier to add new flags as desired w/out
growing the structure.

	unsigned char		local_df,
				cloned,
				pkt_type,
				ip_summed;

The priority could probably be 16 bits as well, do we really need more
than 65k different priorities:

	__u32			priority;

Of course...this might be things for 2.7 since lots of modules will probably
be accessing these fields.  Maybe to get started we could add macros to grab
the flags and such so that when we finally do collapse things into a single
flags field the external code doesn't have to know or care?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
