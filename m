From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: IPv6 connect() from site-local to global IPv6 address.
Date: Sat, 06 May 2006 01:53:26 +0100
Message-ID: <1146876802.2503.32.camel@shinybook.infradead.org>
References: <1146862832.2766.54.camel@pmac.infradead.org>
	 <20060506.091920.122414672.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([205.233.218.70]:41452 "EHLO
	canuck.infradead.org") by vger.kernel.org with ESMTP
	id S1750725AbWEGAkK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 20:40:10 -0400
Received: from shinybook-bcm.infradead.org ([2001:8b0:10b:1:20a:95ff:fef3:9992] helo=shinybook.infradead.org)
	by canuck.infradead.org with esmtpsa (Exim 4.61 #1 (Red Hat Linux))
	id 1FcXJf-00062X-1Y
	for netdev@vger.kernel.org; Sat, 06 May 2006 20:40:09 -0400
Received: from dwmw2 by shinybook.infradead.org with local (Exim 4.62 #1 (Red Hat Linux))
	id 1FcXJV-0008Fr-Hb
	for netdev@vger.kernel.org; Sun, 07 May 2006 01:39:57 +0100
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060506.091920.122414672.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-05-06 at 09:19 +0900, YOSHIFUJI Hideaki wrote:
> You have compatible address.
> Do you really use the tunnel? How did you configure it? 

Sorry, I should have shown a strace from a different machine. Try this
one from an autoconfigured machine...

socket(PF_INET6, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET6, sin6_port=htons(80), inet_pton(AF_INET6, "2001:8b0:10b:1:20d:93ff:fe7a:3f2c", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = 0
getsockname(3, {sa_family=AF_INET6, sin6_port=htons(32837), inet_pton(AF_INET6, "fec0::1:202:b3ff:fe03:45c1", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, [28]) = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET, sin_port=htons(80), sin_addr=inet_addr("81.187.2.168")}, 16) = 0
getsockname(3, {sa_family=AF_INET, sin_port=htons(32837), sin_addr=inet_addr("172.16.18.64")}, [16]) = 0
Trying 2001:8b0:10b:1:20d:93ff:fe7a:3f2c...

There is a default route, because I believe that's the only thing that
radvd can do. I cannot advertise a route to _only_ fec0::/16, can I?


(The machine I showed you before was a router between networks --
the ::172.16.18.67 address was on its tunnel interface, and was added
automatically when I created the tunnel and brought it up.) 

-- 
dwmw2
