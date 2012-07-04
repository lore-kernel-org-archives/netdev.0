From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: RFC: (now non Base64) replace packets already in queue
Date: Wed, 04 Jul 2012 22:32:51 +0200
Message-ID: <4FF4A873.1000001@gmail.com>
References: <FB112703C4930F4ABEBB5B763F96491139378722@MAILSERV2A.lorien.fkie.fgan.de>  <4FEC854E.8080603@hp.com>  <FB112703C4930F4ABEBB5B763F96491139378E5A@MAILSERV2A.lorien.fkie.fgan.de>  <1340960817.15719.6.camel@edumazet-glaptop>  <FB112703C4930F4ABEBB5B763F964911393795D6@MAILSERV2A.lorien.fkie.fgan.de>  <1341214310.5269.27.camel@edumazet-glaptop>  <FB112703C4930F4ABEBB5B763F96491139379643@MAILSERV2A.lorien.fkie.fgan.de>  <4FF20557.4090501@gmail.com> <1341266168.22621.466.camel@edumazet-glaptop> <FB112703C4930F4ABEBB5B763F96491139379DC7@MAILSERV2A.lorien.fkie.fgan.de> <FB112703C4930F4ABEBB5B763F96491139379ECF@MAILSERV2A.lorien.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>
To: "Erdt, Ralph" <ralph.erdt@fkie.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60634 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586Ab2GDUby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 16:31:54 -0400
Received: by eeit10 with SMTP id t10so3014948eei.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 13:31:53 -0700 (PDT)
In-Reply-To: <FB112703C4930F4ABEBB5B763F96491139379ECF@MAILSERV2A.lorien.fkie.fgan.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/07/2012 12:02, Erdt, Ralph a =E9crit :
> My question is: Should I do the work to create and release a kernel p=
atch and make
> it perfect over the time, or is this just our internal code, which I =
can leave at
> the current state? I know our module won't be used widely (too specia=
l), but I'm
> sure, there are a few people out there, which would be thankful for t=
his.

I suggest you try and send a properly formated patch with your code, so=
 that people here can have a=20
look at it and evaluate the interest of integrating it into main line k=
ernel.

That being said, I really think you should try to manage a userspace qu=
eue, in particular if you=20
already have most of the job done in userspace using a tun/tap. I don't=
 know the details of the=20
special device you work with, but if you manage both side of the link, =
you can add many nice=20
features into userspace to enhance the speed/quality :

- Compression (including very clever one if you know the meaning of the=
 data you are transmitting).
- Packet numbering, to allow the remote side to ACK packet, the same wa=
y TCP does.
- Early ACK on TCP, if you get an ACK from the other side of your link =
and you assure that this link=20
is the worst part of the path. This may help TCP to work on this low sp=
eed/high RTT link.

And I really see your packet replacement system as one of those nice fe=
atures and cannot imagine a=20
good reason not to put it in userspace.

	Nicolas.
