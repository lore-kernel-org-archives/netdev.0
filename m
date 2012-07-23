From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Crash in tun
Date: Mon, 23 Jul 2012 10:43:18 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FA1@saturn3.aculab.com>
References: <alpine.DEB.2.00.1207190213001.16299@artax.karlin.mff.cuni.cz> <1342678175.2626.3849.camel@edumazet-glaptop> <alpine.DEB.2.00.1207191746170.7550@artax.karlin.mff.cuni.cz> <20120720.112337.474955511809249636.davem@davemloft.net> <20120721075518.GY31729@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mikulas@artax.karlin.mff.cuni.cz>, <eric.dumazet@gmail.com>,
	<maxk@qualcomm.com>, <vtun@office.satix.net>,
	<netdev@vger.kernel.org>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	<linux-sctp@vger.kernel.org>
To: "Al Viro" <viro@ZenIV.linux.org.uk>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45623 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750969Ab2GWJoK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 05:44:10 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01941-04 for <netdev@vger.kernel.org>;
 Mon, 23 Jul 2012 10:44:03 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20120721075518.GY31729@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 	BTW, speaking of struct file treatment related to sockets -
> there's this piece of code in iscsi:
>         /*
>          * The SCTP stack needs struct socket->file.
>          */
>         if ((np->np_network_transport == ISCSI_SCTP_TCP) ||
>             (np->np_network_transport == ISCSI_SCTP_UDP)) {
>                 if (!new_sock->file) {
>                         new_sock->file = kzalloc(
>                                         sizeof(struct file),
> GFP_KERNEL);
> 
> For one thing, as far as I can see it'not true - sctp does *not*
> depend on socket->file being non-NULL; it does, in one place,
> check socket->file->f_flags for O_NONBLOCK, but there it treats
> NULL socket->file as "flag no set".

The SCTP code certainly has unconditionally looked at file->f_flags,
we had to allocate a 'struct file' for our in-kernel socket code.
We set sock->file = NULL before the sock_release() call so
hopefully don't suffer the 'side effects'.

	David
