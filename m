From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Fri, 29 Oct 2004 16:56:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182D8A1.1070801@candelatech.com>
References: <41797696.9070905@candelatech.com>	 <20041022214611.GA4948@electric-eye.fr.zoreil.com>	 <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>	 <4181838B.6040002@tpack.net>  <41818D99.9020300@candelatech.com> <1099038566.1813.99.camel@cyan.cph.tpack.net> <418281C1.9080707@candelatech.com> <4182D44E.7070507@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4182D44E.7070507@tpack.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> Ben Greear wrote:
> 

>> You can't send shared skbs regardless, because the vlan Xmit changes 
>> the skb->dev at least, so
>> you just have to set the multi-skb setting in pktgen to 0 so that it 
>> does not
>> share when using VLANs.
> 
> 
> By sheer accident, this would actually work! Nevertheless, the code
> should obviously handle this correctly (whatever that means?!).

It definately crashed on my system when I tried it, so I don't think
it actually works.  Think about a SMP system where pktgen is re-sending
the same pkt while the other CPU is handling the previous send..or something
like that.  The fact that skb->dev is changing cannot be healthy.

 From what I can tell, a net-devices hard_start_xmit method must either
return 0 and consume the skb, or return a non-zero value and not
consume the skb.  Since we can detect immediate drops due to the
dev_queue_xmit call failing, I don't see how it can hurt anything to
preserve the skb and return the error code.  Code that cares about retransmitting
can, and if it doesn't, it can just delete the skb.

I believe this is the same as the case where the e1000 does not
show netif_queue_stopped() but still returns failure when you
try the hard_start_xmit.  I know that this case will probably
eventually be fixed, but the fact that it *does* work leads me to
believe I can get away with what I'm trying to do with VLANs.

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
