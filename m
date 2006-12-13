From: Michael Buesch <mb@bu3sch.de>
Subject: d80211: The struct ieee80211_hw_modes array is a pain
Date: Wed, 13 Dec 2006 11:42:20 +0100
Message-ID: <200612131142.20556.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:51918
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655AbWLMLG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 06:06:28 -0500
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am currently porting the bcm43xx driver to my new Sonics
Silicon Backplane busdriver.
I am having a major pain implementing the hw->modes field
for this. In particular, the problem is allocation.
I always felt sick about hw->modes, but with my new code it's
damn complicated to get allocation of the stuff right.
The problem is, that I do not know in advance which PHYMODEs
my device supports (in fact, we never knew that, but we worked
around it (in a broken way)).
We have the following scenario: The PHYs are probed one after
each other. We have one data structure per PHY. This bites
the static hw->modes array in its ass. I would either have to
allocate it "big enough" at the first time (wasting lots of memory)
or I'd have to re-allocate it every time a new PHY is probed.
Another (much harder to fix) problem is the opposite of the probing:
Removing the PHYs.

So, what I'd like to have is:

One struct ieee802111_hw_mode which I can embed into the PHY
data structure. This struct is now dynamically registered to the
ieee80211 subsystem (instead of doing a static array pain).

Registering and unregistering would be done with simple linked lists,
perhaps, in d80211.

If nobody has any objections against this approach, I will do a
patch soon.

-- 
Greetings Michael.
