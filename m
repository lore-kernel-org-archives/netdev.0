From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Fri, 30 Jun 2006 10:39:06 +1000
Message-ID: <20060630003906.GA27200@gondor.apana.org.au>
References: <Pine.GSO.4.10.10606291810490.12773-100000@guinness> <E1Fw604-0006yP-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, shemminger@osdl.org,
	Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	sivakumar.subramani@neterion.com, Sriram.Rapuru@neterion.com,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:23556 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751352AbWF3Ajz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 20:39:55 -0400
To: Ananda Raju <Ananda.Raju@neterion.com>
Content-Disposition: inline
In-Reply-To: <E1Fw604-0006yP-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 30, 2006 at 09:32:44AM +1000, Herbert Xu wrote:
> 
> > diff -upNr netdev.org/include/linux/skbuff.h netdev.ipv6_tso/include/linux/skbuff.h
> > --- netdev.org/include/linux/skbuff.h   2006-06-27 07:30:36.000000000 -0700
> > +++ netdev.ipv6_tso/include/linux/skbuff.h      2006-06-27 07:38:48.000000000 -0700
> > @@ -170,8 +170,9 @@ enum {
> > };
> > 
> > enum {
> > -       SKB_GSO_TCPV4 = 1 << 0,
> > -       SKB_GSO_UDPV4 = 1 << 1,
> > +       SKB_GSO_TCP = 1 << 0,
> > +       SKB_GSO_UDP = 1 << 1,
> > +       SKB_GSO_TCPV6 = 1 << 2,
> > };
> 
> BTW, you should rediff against Dave's current tree which has a few
> extra bits there.
> 
> You should also leave TCPV4 as is and just add the TCPV6 bit.

BTW, does your card handle ECN correctly? If not then we should change
the new ECN bit to apply to both TCPv4 and TCPv6 since

1) We now have a piece of hardware that handles TSO6 and it doesn't do ECN.
2) It's quite likely that if the NIC can handle ECN in TCPv4 then it can do
   it in TCPv6.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
