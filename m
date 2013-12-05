From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: Supporting 4 way connections in LKSCTP
Date: Thu, 5 Dec 2013 09:35:40 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7460@saturn3.aculab.com>
References: <CAFXGft+CXk3W8=3w=AuYzqYtYnR8nH4Of9=668tUeT+tugD9-A@mail.gmail.com>	<CAFXGftJQV=5Pqs3bhfiS3T1VO1q8jfaMjAUiqm2tDbtSyBCM3A@mail.gmail.com>	<529C9B50.50002@gmail.com>	<CAGugRbXFirQ5P3ek9zN86h4vvO6qsy3eNEooJOApotA+dL+C_g@mail.gmail.com>	<529CB859.9090904@gmail.com>	<CAFXGft+F52p+oaa59=5e5pGfON44N36NA-XMYi5PorzWeybnKw@mail.gmail.com>	<CAFXGft+4o6fT4SYbu3musC+-BEi=xOEGUbZSavF1-0_V1mg6zg@mail.gmail.com>	<529D3BF9.3070208@gmail.com>	<CAFXGftJtCCJ=pVxg_DH-+n2bKmoKXavog0y8mfX+h-1z3hP49Q@mail.gmail.com>	<529DCF42.1070800@gmail.com>	<CAFXGftK5tz90OzObiV7Hi+g080j3zWCNdo217CKdNkOY4JWQUg@mail.gmail.com>	<529DF73E.7060604@gmail.com> <CAFXGftKZD0zN1S=UTa_bYr71-v=7mzU=_CewTNkjPv9CGGB_Fg@mail.gmail.com> <529F395B.9040308@gmail.com> <AE90C24D6B3A694183C094C60CF0A2F6026B745D@saturn3.aculab.com> <5
 29F4D1A.3050304@gmail.com> <7A4B9BD9-B2BF-4625-A2E5-500CD4A6D399@lurchi.franken.de> <529F5472.9030207@gmail.com> <4F0BC498-2F09-4DB6-83DC-82571645476B@lurchi.franken.de> <529F7336.1000007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Sun Paul" <paulrbk@gmail.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, "Karl Heiss" <kheiss@gmail.com>,
	"Neil Horman" <nhorman@tuxdriver.com>,
	<linux-kernel@vger.kernel.org>
To: "Vlad Yasevich" <vyasevich@gmail.com>,
	"Michael Tuexen" <Michael.Tuexen@lurchi.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44828 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752746Ab3LEJgs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 04:36:48 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20569-08 for <netdev@vger.kernel.org>;
 Thu,  5 Dec 2013 09:36:44 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <529F7336.1000007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> the configured addresses could be:
> >> System A) 10.0.0.1 on Lan X, 10.10.0.1 on Lan Y
> >> System B) 10.0.0.2 on Lan X, 10.10.0.2 on Lan Y
> >> System C) 10.0.0.3 on Lan X, 10.10.0.2 on Lan Z
> >>
> >> Same problem will occur.
...
> With that, Sys A talking to Sys C will get an abort
> from Sys B when trying to talk to 10.10.0.2.  With /8, it'll be
> even worse since SysB and SysC will have duplicate addresses
> within the subnet. :)
> 
> The point is that you don't always know that the same private subnet
> is in reality 2 different subnets with duplicate addresses.
> 
> I've had to debug an actual production issue similar to this where
> customer had a very similar configuration to above, and their
> associations kept getting aborted.  When I tried accessing the
> system that kept sending aborts, I found it was some windows
> server and not a Diameter station they were expecting.

Does seem that the addresses listed in INIT and INIT_ACK chunks
should be ignored until a valid HB response has been received.
If an abort is received before a valid HB response then the
address should be ignored rather than the connection aborted.
Then it wouldn't matter anywhere near as much if addresses are
advertised that are not reachable from the remote system.

All this should have been thought about when the original RFC
was written.

	David
