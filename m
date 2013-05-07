From: Julian Anastasov <ja@ssi.bg>
Subject: Re: source IP address for ARP requests
Date: Tue, 7 May 2013 22:33:14 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1305072224040.1693@ja.ssi.bg>
References: <51891E0D.7050907@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46994 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752173Ab3EGTay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 May 2013 15:30:54 -0400
In-Reply-To: <51891E0D.7050907@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 7 May 2013, Michael Tokarev wrote:

> Hello.
> 
> With a somewhat unusual configuration:
> 
>  eth0  10.0.0.1/32
>  eth1  192.168.1.1/24
>  route add 10.0.0.2 dev eth1 src 10.0.0.1
> 
> namely, so that just one ip address is available
> on an "unrelated" subnet, with "our" address taken
> from another interface.
> 
> With this config, ARPs for 10.0.0.2 are sent to eth1
> with source address of 192.168.1.1, even if "src"
> is configured for the route in question:
> 
>  9:28:46.220680 ARP, Request who-has 10.0.0.2 tell 192.168.1.1, length 28
> 
> Is that right, or should the host send ARP requests
> with src=10.0.0.1?
> 
> This is kernel 3.2(.40).

	IIRC, it works in this way from 2.4+. I guess some
packet from 192.168.1.1 to 10.0.0.2 triggers such ARP request.
The kernel prefers to copy the addresses from IP header to
the ARP request, it can be tuned with arp_announce, you can
check Documentation/networking/ip-sysctl.txt

Regards

--
Julian Anastasov <ja@ssi.bg>
