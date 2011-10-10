From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mlx4_en: fix transmit of packages when blue frame is enabled
Date: Mon, 10 Oct 2011 09:40:17 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AE78@saturn3.aculab.com>
References: <1318145118.29415.371.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, "Eli Cohen" <eli@mellanox.co.il>,
	<linuxppc-dev@lists.ozlabs.org>,
	"Thadeu Lima de Souza Cascardo" <cascardo@linux.vnet.ibm.com>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.co.il>
To: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"Eli Cohen" <eli@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:39750 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752193Ab1JJIl3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 04:41:29 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08802-05 for <netdev@vger.kernel.org>;
 Mon, 10 Oct 2011 09:41:23 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1318145118.29415.371.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> What is this __iowrite64_copy... oh I see
> 
> Nice, somebody _AGAIN_ added a bunch of "generic" IO 
> accessors that are utterly wrong on all archs except
> x86 (ok, -almost-).
> There isn't a single bloody memory barrier in there !

Actually memory barriers shouldn't really be added to
any of these 'accessor' functions.
(Or, at least, ones without barriers should be provided.)

The driver may want to to a series of writes, then a
single barrier, before a final write of a command (etc).

in_le32() from io.h is specially horrid!

	David
