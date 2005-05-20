From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 19:30:01 -0400
Message-ID: <428E72F9.3070404@pobox.com>
References: <1116609329.31523.16.camel@rh4>	<20050520194220.GA18259@havoc.gtf.org> <20050520.152836.48528379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@oss.sgi.com, ffan@broadcom.com,
        lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
In-Reply-To: <20050520.152836.48528379.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S.Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 20 May 2005 15:42:20 -0400
>>10) [additional review] doesn't bnx2_rx_int() need to move the rmb()
>>inside the loop?  Are you protecting against the compiler
>>reordering/caching loads/stores, or against SMP CPUs?
> 
> 
> This rmb() is needed to strongly order the status block consumer
> index read, from that of the descriptor data.  I'm pretty sure it's
> in the right spot.
> 
> 
>>10.1) [additional review] is the rmb() even needed in bnx2_rx_int(),
>>since its caller also uses rmb()?
> 
> 
> No, it's guarding status block consumer index read to the first
> RX descriptor read, as explained above.

OK


>>13) [additional review] why is CHECKSUM_UNNECESSARY used when
>>cksum==0xffff or cksum==0 ?
>>
>>+                       u16 cksum = rx_hdr->l2_fhdr_tcp_udp_xsum;
>>+
>>+                       if ((cksum == 0xffff) || (cksum == 0)) {
>>+                               skb->ip_summed = CHECKSUM_UNNECESSARY;
>>+                       }
> 
> 
> For UDP, a checksum value of zero means no checksum at all.

Sure.  What I'm driving at is that a checksum of zero seems to imply 
CHECKSUM_NONE not CHECKSUM_UNNECESSARY.  tg3 only does the 0xffff check.

I am also a bit surprised that, if the actual checksum value is 
available, why not use CHECKSUM_HW like sunhme?

	Jeff
