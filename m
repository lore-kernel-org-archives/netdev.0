From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: [PATCH 00/10] SFQ: backport some features from ESFQ (try 3)
Date: Sat, 25 Aug 2007 15:26:54 -0700
Message-ID: <11880808243166-git-send-email-bugfood-ml@fatooh.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:35045 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757596AbXHYW1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 18:27:05 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id 6A9BC17C313
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2007 17:27:06 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id C5SnxdxziJ4s for <netdev@vger.kernel.org>;
	Sat, 25 Aug 2007 17:27:06 -0500 (CDT)
Received: from bugfood (c-76-102-59-34.hsd1.ca.comcast.net [76.102.59.34])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id 0618F17C212
	for <netdev@vger.kernel.org>; Sat, 25 Aug 2007 17:27:05 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patchset try 2 addresses the review by Michael Buesch.
Patchset try 3 addresses the review by Patrick McHardy.

The first 7 patches in this series resemble the corresponding 7 patches
I sent previously. There aren't any major changes--just modifications
to address errors noticed in review and slight reorganizations to make
the next patches easier.

Patches 8-10 implement parameter passing via nested compat attributes.
This is necessary for using 'tc qdisc change' to disable perturbation.
The rest of the parameters were added for consistency.

Iproute2 patches will follow shortly.



The following is the original patch text.

This set of patches adds some of ESFQ's modifications to the original 
SFQ. Thus far, I have received support for this approach rather than for 
trying to get ESFQ included as a separate qdisc.

http://mailman.ds9a.nl/pipermail/lartc/2007q2/021056.html

My patches here implement "tc qdisc change", user-configurable depth 
(number of flows), and user-configurable divisor (for setting hash table 
size). I've left out the remaining ESFQ features (usage of jhash and 
different hashing methods) because Patrick McHardy intends to submit a 
patch that will supersede that functionality; see the URL above.

Default values remain the same, and SFQ's default behavior remains the 
same, so there should be no user disruption.

Thanks for your consideration,
Corey



 include/linux/pkt_sched.h |   23 ++-
 net/sched/sch_sfq.c       |  356 ++++++++++++++++++++++++++++++--------------
 2 files changed, 257 insertions(+), 122 deletions(-)


[PATCH 01/10] Preparatory refactoring part 1.
[PATCH 02/10] Preparatory refactoring part 2.
[PATCH 03/10] Move two functions.
[PATCH 04/10] Make "depth" (number of queues) user-configurable:
[PATCH 05/10] Add divisor.
[PATCH 06/10] Make qdisc changeable.
[PATCH 07/10] Remove comments about hardcoded values.
[PATCH 08/10] Multiply perturb_period by HZ when used rather than when assigned.
[PATCH 09/10] Change perturb_period to unsigned.
[PATCH 10/10] Use nested compat attributes to pass parameters.


