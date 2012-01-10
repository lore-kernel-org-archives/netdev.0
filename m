From: Dave Jones <davej@redhat.com>
Subject: iwlwifi worse than ever in current git.
Date: Tue, 10 Jan 2012 13:49:18 -0500
Message-ID: <20120110184917.GA26973@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: emmanuel.grumbach@intel.com, wey-yi.w.guy@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755320Ab2AJStV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jan 2012 13:49:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the last few releases, iwlwifi has been getting consistently worse
wrt reliability for me.  The failure mode has varied, from the chip just
locking up with no tx/rx of packets with nothing being logged, to
microcode warnings, and spewing 'Tx aggregation enabled' messages over and over.

The merge post 3.2 has made these problems a lot worse.  Before, these
lock-ups were happening once or twice a day. Now they happen several times an hour
(and after the first one, they seem more frequent). When they happen,
unloading and reloading the module is the only way for me to get working wireless again.
They may happen more frequently when the laptop is not idle.

I did a bisect of the changes since 3.2, which pointed at 76bc10fcd128ad028cf77c62e179cd20dc2ffecf
as being the culprit, but to be honest I'm not 100% convinced.

Because every step of the way during the bisect, I saw different failure modes,
so when I marked something as 'good', it meant "doesn't lock up in the same way",
even though it may be symptomatic of the same problem.

The specific chip I'm using is a 5300 in a Dell Adamo, connecting to
an Apple airport extreme (current model) in N mode.

	Dave
