From: pacman@kosh.dhis.org
Subject: mv643xx pegasos breakage again
Date: Tue, 21 Sep 2010 16:06:39 -0500 (GMT+5)
Message-ID: <20100921210639.20777.qmail@kosh.dhis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-69-245-226-104.hsd1.in.comcast.net ([69.245.226.104]:33776
	"HELO kosh.dhis.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754149Ab0IUVNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:13:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Long ago, in another thread started by me,

Lennert Buytenhek wrote:
>Also, since the mv643xx_eth phylib conversion, it appears that the
>PHY on the Pegasos board fails to initialise properly, and this can
>apparently be worked around by turning the Marvell phylib driver off.
>Are you seeing this as well?

Gabriel Paubert answered:
>At least I experienced this problem. On the Pegasos, the generic
>PHY driver works, the Marvell specific ones screws up (at least 
>when connected to a 100Mb/s hub, it detects it as 1Gb). 

I didn't have anything to add at the time, having never actually tried the
marvell phy driver, and I quickly forgot about the issue. But now I've put a
2.6.35 kernel on a pegasos, and the marvell phy driver is being autoloaded.
The above symptom appears. Previously, it was possible to have the offending
driver harmlessly sitting in /lib/modules and as long as it wasn't loaded,
things were OK.

The misdetected speed is only the first symptom. No packets are ever
received, even after manually setting the speed.

Also during one experiment, the kernel allowed me to rmmod marvell and then
Oopsed, which I thought was a little rude.

It's still easy to work around: just don't build that driver.

Since this "new" problem was hard for me to identify (the marvell phy driver
doesn't announce itself in the kernel log, so there was no obvious sign that
a different driver was being loaded, and I had to git bisect to figure out
what happened between 2.6.34 and 2.6.35) I figure I should at least put my
solution on the record. And volunteer for further testing in case someone is
interested in digging deeper into why pegasos doesn't like marvell.ko.

