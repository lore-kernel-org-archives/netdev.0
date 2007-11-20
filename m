From: Roland McGrath <roland@redhat.com>
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 14:54:57 -0800 (PST)
Message-ID: <20071120225457.B6E2D26F8BE@magilla.localdomain>
References: <20071119191000.GA1560@elf.ucw.cz>
	<200711192304.25087.rjw@sisk.pl>
	<4743026B.2020907@openvz.org>
	<m11wakshyz.fsf@ebiederm.dsl.xmission.com>
	<20071120215914.GE24156@elte.hu>
	<m1ve7wr28z.fsf@ebiederm.dsl.xmission.com>
	<20071120223559.GA6655@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ulrich Drepper <drepper@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbXKTWzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 17:55:00 -0500
In-Reply-To: Ingo Molnar's message of  Tuesday, 20 November 2007 23:35:59 +0100 <20071120223559.GA6655@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When did /proc/self get changed to follow tgid instead of pid?  glibc uses
/proc/self to refer to various things that are usually shared anyway (fd,
maps, cwd, exe), but I think the expectation has always been that this
refers to the same calling thread, not the group leader.  e.g., if one
thread has changed uids so it no longer has access to the group leader's
/proc/PID/fd, suddenly it using /proc/self/fd starts failing.


Thanks,
Roland
