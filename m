From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 5 Jan 2005 06:26:32 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0501050604390.27046@hibernia.jakma.org>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
 <1104764710.1048.580.camel@jzny.localdomain> <41DB26A6.2070008@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: hadi@cyberus.ca, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <41DB26A6.2070008@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 4 Jan 2005, Jeff Garzik wrote:

> Aren't there cases where people would -not- want the queue to be 
> cleared?

Why *do* you want the queue to be cleared? (avoiding NIC /dev/null is 
only reason right?)

TCP (AIUI) has its owns means to resend.

Most (all?) other transports have *never* had an expectation of such 
reliability. Applications *know* they have to provide their own 
reliability. Queueing and later sending (by then) stale packets is 
*bad*

Think:

- heartbeat applications
- Router or route advertisements (IPv6 RA, IPv4 ICMP IRDP, RIP)
- Streaming media (ok, not much damage here, but still there's simply
   no point queueing while link is down..)

Why queue packets on behalf of applications which have no expectation 
of kernel doing this (any application expecting such is certainlty 
broken) and which very likely implement their own reliability or 
packet-loss recovery strategies? Particularly when queueing is quite 
possibly *detrimental* to what the application is trying to achieve 
(timely sending of packets).

If an application wants reliable sending of packets, it will be using 
TCP..

> 	Jeff

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
When the speaker and he to whom he is speaks do not understand, that is
metaphysics.
 		-- Voltaire
