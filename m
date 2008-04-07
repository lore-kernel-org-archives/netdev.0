From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6 0/3]: TCP fixes
Date: Mon,  7 Apr 2008 14:25:34 +0300
Message-ID: <1207567537-16393-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Robin H. Johnson" <robbat2@gentoo.org>,
	Georgi Chorbadzhiyski <gf@unixsol.org>,
	Soeren Sonnenburg <kernel@nn7.de>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Alessandro Suardi <alessandro.suardi@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53225 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbYDGLZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 07:25:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here are some TCP fixes that resulted from the last weeks reports
& debug. The first one is quite likely to hit but it's considerably
harder to get it print an overflow warning, while I've seen two
reports about the second one (one of them is for 2.6.24.y), please
ignore the earlier version of the tcp_simple_retransmit patch. The
FRTO patch is once again result of code review rather than some   
report but seems necessary to avoid detection of some not that    
likely cases as spurious RTOs when there were some other losses
in the same window with the probe. Nevertheless, it should be safe
to return non-FRTO behavior.

...So far, they're just compile tested. I'll see if I find some time
to boot them on the evening.

There might still be one fackets_out miscounter awaiting detection
with debug patch (I hope Georgi catches it) because none of these   
seem an obvious reason for triggery of the !sacked_out && fackets_out
trap.

All of them are also valid for stables but please note that it won't
be too easy, at least for the first & second patch, because of recent
changes (especially if stable != 2.6.24.y). I'll try to do the
adapted versions later on for the stable.

--
 i.


