From: Michael Buesch <mb@bu3sch.de>
Subject: Suspending 802.11 drivers
Date: Thu, 15 Jun 2006 21:58:09 +0200
Message-ID: <200606152158.10079.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:4334
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1031234AbWFOT7F
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 15:59:05 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am currently thinking about the best way to correctly
implement PM suspending for wireless drivers.
Currently, the 802.11 stack is not suspend aware (if I talk
about "stack" here, I mostly mean devicescape).
For example, if we suspend the bcm43xx driver, we don't
notify the stack before doing so. That's a bug.

I would say, we should have two functions, which are called
from the driver suspend and resume callbacks.
Let's call them
ieee80211_suspend() and ieee80211_resume() for now.
The suspend would save all status information, for example
to which AP we are associated and so on. After that it would
cleanly disassociate from the AP and do other cleanups which
are needed.
The resume function would try to re-esablish the connection.
Of course, that will not always be possible (the notebook
owner traveled around half the world between suspend and
resume ;) ). But that does not matter. We simply return silently
without a new association (Do a new scan, or whatever).

Are such functions generally desireable?

-- 
Greetings Michael.
