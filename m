From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 9/9] batman-adv: Use packing of 2 for all headers before an ethernet header
Date: Wed, 21 Nov 2012 13:36:54 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70BB@saturn3.aculab.com>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org> <1353499919-28596-10-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <b.a.t.m.a.n@lists.open-mesh.org>,
	"Sven Eckelmann" <sven@narfation.org>,
	"Marek Lindner" <lindner_marek@yahoo.de>
To: "Antonio Quartulli" <ordex@autistici.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51034 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751640Ab2KUNiG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 08:38:06 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21530-04 for <netdev@vger.kernel.org>;
 Wed, 21 Nov 2012 13:37:55 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1353499919-28596-10-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> All packet headers in front of an ethernet header have to be completely
> divisible by 2 but not by 4 to make the payload after the ethernet header again
> 4 bytes boundary aligned.

I'm not sure that statement is correct - whether the patches are
correct rather depends on the actual packet format(s) you are
generating/modifying.

If you are adding data to an ethernet packet you'll need
to add a multiple of 4 bytes in order maintain the alignment
of the IP header (which needs to be 4 byte aligned and is
usually 14 bytes from the start of the receive data).

This means that the data you add probably has to be 4n+2
aligned - since I guess you are adding between the source
MAC address and ethertype?
If you are inserting data after the ethertype (ie after some
protocol identifier), then your header can be 4 byte aligned
provided it ends with the replacement ethertype (0800 or 0806
for IP protocols).

	David
