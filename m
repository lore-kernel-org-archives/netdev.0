From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [B.A.T.M.A.N.] [PATCH] Fix ARM BUILD_BUG_ON() errors withbatman-adv
Date: Mon, 2 Dec 2013 10:24:17 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7451@saturn3.aculab.com>
References: <20131130191553.GA16735@n2100.arm.linux.org.uk> <529A46C4.9090906@meshcoding.com> <20131130230518.GC16735@n2100.arm.linux.org.uk> <529A8276.9060002@meshcoding.com> <529B47AA.8060403@meshcoding.com> <20131201171309.GD16735@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "The list for a Better Approach To Mobile Ad-hoc Networking"
	<b.a.t.m.a.n@lists.open-mesh.org>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	"Antonio Quartulli" <antonio@meshcoding.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49397 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753001Ab3LBK0M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 05:26:12 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10365-03 for <netdev@vger.kernel.org>;
 Mon,  2 Dec 2013 10:26:07 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131201171309.GD16735@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The ARM compilers have for the last 20 years always aligned the size of
> structs to a multiple of 32 bits to ensure that members following a
> structure are appropriately aligned.

ARM has (or had) another one for the unwary, bitfields were also
always 32bits.

...
> The only solutions are: use the GCC packed attribute, redesign the
> structures...

It is probably enough to mark the inner structure containing the three
byte fields 'packed'.
Marking it aligned(1) might also have the desired effect.
The outer structure should then be ok.
But would need to use a specially named attribute so it doesn't
get removed.

In the past I've had to replace a struct with an array in order
to avoid a similar alignment rule for structs.

	David
