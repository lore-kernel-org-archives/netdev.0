From: Julian Anastasov <ja@ssi.bg>
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 00:15:09 +0000 (GMT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0208140004530.1212-100000@u.domain.uli>
References: <1029258874.772.97.camel@tux>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Josefsson <gandalf@wlug.westbo.se>
In-Reply-To: <1029258874.772.97.camel@tux>
List-Id: netdev.vger.kernel.org


	Hello,

On 13 Aug 2002, Martin Josefsson wrote:

> On Tue, 2002-08-13 at 15:58, kuznet@ms2.inr.ac.ru wrote:
>
> > Very strange. We have similar phenomenon reported with TCP, by the way.
> > So, I have to assume that checksumming routine is wrong and does some shit
> > sort of relying on an uninitialized data.
>
> I've added some debug printk's and found out that it's the call to
> csum_fold that fails in skb_copy_and_csum_datagram_iovec.

	What about the known problem with csum_partial called
with zero length. IIRC, on CONFIG_X86_USE_PPRO_CHECKSUM compilation
this function depends on the data alignment (addr&2!=0 => bug) - calling 
csum_partial with zero length in 2.4+ is a bug, checks should be added
in the caller. Can this be problem with skb_copy_and_csum_datagram_iovec? 
I see that net/ipv6/raw.c provides 0 as hlen.

Regards

--
Julian Anastasov <ja@ssi.bg>
