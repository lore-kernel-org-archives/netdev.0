From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6 IPSEC + SNAT
Date: Sun, 7 Dec 2003 20:33:24 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031207093324.GA2520@gondor.apana.org.au>
References: <20031001121648.GA8755@gondor.apana.org.au> <200310071251.QAA32679@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200310071251.QAA32679@yakov.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 07, 2003 at 04:51:22PM +0400, kuznet@ms2.inr.ac.ru wrote:
> 
> I thought about this (ages ago, so this can be stale)
> The verdict was that self-consistent picture is possible only
> when NAT rules are integral part of SPD. It does not look like
> a stimulating idea. :-)

I've hit this issue again recently [1] so I'd like to know if
you've had any new revelations on this.

It seems to me that for the forward path at least, there is no issue
with breaking the routing/xfrm_lookup couple, and turning it into
routing/FORWARD/POSTROUTING1/xfrm_lookup/xfrm_output/POSTROUTING2.
Do you agree with this?

If so, then the problem is restricted to the case of locally generated
packets.  Which leads us back to the previous discussion about what
you're going to do with the xfrm_lookup calls on TCP/UDP/RAW sockets.
Can you give an update on your work on that?

Thanks,

[1] The setup is as follows:

Client <-----> Gateway <-----> Internet
	IPSEC

If the gateway does SNAT and the client starts an active FTP connection,
then the TCP sequence numbers may have to be modified.  This is OK on
the way out, but on the way back to the client, the sequence change can
only occur in POSTROUTING which unfortunately occurs after IPSEC
encapsulation.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
