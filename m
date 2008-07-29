From: Kostya B <bkostya@hotmail.com>
Subject: __do_softirq execution context
Date: Tue, 29 Jul 2008 06:12:04 +0000
Message-ID: <BAY121-W10FA0ADF0B41AF147B9FE2B6820@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s32.bay0.hotmail.com ([65.54.246.104]:46735 "EHLO
	bay0-omc1-s32.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751826AbYG2GSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 02:18:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello netdev,

Please put your thoughts on the following:

__do_softirq could be executed from interrupt, ksoftirqd or event userspace process context. There is a mechanism of limiting userspace employment in that task and waking up the ksoftirqd.

In the case of real-time userspace process, such behavior may yield severe outcomes.
May be it will better not to employ such process at all.  Just check has_rt_policy() and immediately wakeup ksoftirqd?


By now, how network driver poll() could differentiate in which context it runs? Both cases (ksoftirqd and userspace) answer positively on in_interrupt()?

Regards,
- Kostya

_________________________________________________________________
Explore the seven wonders of the world
http://search.msn.com/results.aspx?q=7+wonders+world&mkt=en-US&form=QBRE
