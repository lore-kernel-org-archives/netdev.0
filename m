From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: [Bug 4279] New: When I try to start vpnc the net/core/skbuff.c:91
 crash
Date: Fri, 11 Mar 2005 06:03:14 +0100
Message-ID: <42312692.7040806@trash.net>
References: <20050303095832.6a084856@dxpl.pdx.osdl.net>	<4228A354.8020904@qualcomm.com>	<4228AD8F.4020000@trash.net> <20050310192023.1270fef6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, shemminger@osdl.org, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050310192023.1270fef6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>>This check is wrong, gcc optimizes it away:
>>
>>                if ((len -= sizeof(pi)) > len)
>>			return -EINVAL;
>>
>>This could be responsible for the BUG. If len is 2 or 3 and TUN_NO_PI
>>isn't set it underflows. alloc_skb() allocates len + 2, which is 0 or
>>1 byte. skb_reserve tries to reserve 2 bytes and things explode in
>>skb_put.
> 
> Good catch Patrick.
> 
> Patch applied, thanks.

The patch is also needed (and applies with fuzz) for 2.4.

Regards
Patrick
