From: Jeremy Jackson <jerj@coplanar.net>
Subject: solutions for forcedeth jumbo rx and order:2 alloc?
Date: Fri, 18 Dec 2009 12:52:22 -0500
Message-ID: <1261158742.4932.190.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:37431 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbZLRSFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 13:05:38 -0500
Received: from [70.47.139.174] (ragnarok.coplanar.net [70.47.139.174] (may be forged))
	(authenticated bits=0)
	by titan.coplanar.net (8.14.2/8.14.2/Debian-2build1) with ESMTP id nBIHqZ4b006817
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 12:52:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, forcedeth seems to want an order:2 alloc for each frame rx.
I find this behaviour makes using 9100 byte jumbos somewhat suicidal O.o
Frequent kernel messages, failure of bridge STP (the goggles, they do
nothing!) due to missed packets, etc.

I realize that it's a reverse engineered driver, and that changing the
way hardware descriptors works to use paged SKBs might be very
difficult, so I'm wondering if the following would work:

Allocate linear static buffers for use in rx ring descriptors once at
device init time (ifconfig up), and copy into paged skbs when handing >
page sized SKBs up to higher layer network stack?  (hmm did i just ask
to copy every rx packet?)

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

