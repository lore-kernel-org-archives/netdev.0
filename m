From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.24-rc3: find complains about /proc/net
Date: Tue, 20 Nov 2007 17:47:32 -0700
Message-ID: <m1y7cspgpn.fsf@ebiederm.dsl.xmission.com>
References: <4743026B.2020907@openvz.org>
	<m11wakshyz.fsf@ebiederm.dsl.xmission.com>
	<20071120215914.GE24156@elte.hu>
	<m1ve7wr28z.fsf@ebiederm.dsl.xmission.com>
	<20071120223559.GA6655@elte.hu>
	<20071120225457.B6E2D26F8BE@magilla.localdomain>
	<20071120230106.GD24380@elte.hu>
	<3d8471ca0711201506t6b2b88a0h9484f8a40a1f2e40@mail.gmail.com>
	<20071120232600.F1D2F26F8BE@magilla.localdomain>
	<47436E7F.2060901@redhat.com> <20071120234505.GF23667@elte.hu>
	<20071120235114.0B85226F8BE@magilla.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Ulrich Drepper <drepper@redhat.com>,
	Guillaume Chazarain <guichaz@yahoo.fr>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Roland McGrath <roland@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:58217 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758376AbXKUAtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 19:49:07 -0500
In-Reply-To: <20071120235114.0B85226F8BE@magilla.localdomain> (Roland
	McGrath's message of "Tue, 20 Nov 2007 15:51:14 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland McGrath <roland@redhat.com> writes:

>> can you see any danger to providing a /proc/self_task/ link? (or can you 
>> think of a better name/API/approach)
>
> That is a poor name to choose given /proc/self/task exists as something
> else (just try writing a sentence comparing them and then read it aloud).
> Probably /proc/self/task/self is what makes the most sense structurally.
> I don't know if it matters to whatever use you are concerned with to have
> two more steps in the lookup.

Well the only case it could matter is if you aren't allowed to access
/proc/<tgid> which I think may actually be the current selinux behavior.

So if we can't fix /proc/self we need to introduce /proc/task-self at
the top level, just to be certain we don't run into weird cases like
that.  Otherwise /proc/self/task/self sounds like a wonderful suggestion.

Eric
