From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/2] (Was: pppd service crash in linux-3.13.6)
Date: Mon, 17 Mar 2014 19:04:16 +0100
Message-ID: <20140317180416.GA15708@redhat.com>
References: <531A37FF.4000509@totakura.in> <531DEEA6.4090808@totakura.in> <531E111A.8040207@hurleysoftware.com> <20140313170622.GA31206@redhat.com> <5321F113.7090000@hurleysoftware.com> <53230FE5.9020204@hurleysoftware.com> <20140314192346.GA14823@redhat.com> <53236662.3020707@hurleysoftware.com> <20140314210456.GA19032@redhat.com> <53244C61.5090508@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sree Harsha Totakura <sreeharsha@totakura.in>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>
To: Peter Hurley <peter@hurleysoftware.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53244C61.5090508@hurleysoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15, Peter Hurley wrote:
>
> On 03/14/2014 05:04 PM, Oleg Nesterov wrote:
>>
>> But it can't even know who called call_usermodehelper(). Besides,
>> cgroup_release_agent() uses UMH_WAIT_EXEC, so the caller can continue
>> and disappear completely before the usermode process has any chance
>> to do something.
>
> I'm just hypothesizing potential breakage, since the order of teardown
> is sensitive to changes, and I didn't do a complete audit of all the
> possibilities.

Yes, I understand your concerns. Still I do not see how cgroup_exit()
can depend on tty/namespace.

> If you feel strongly about moving disassociate_tty(), I won't object.

It is not that I feel really strongly... just in looks better to me.
If nothing else:

	1. If we actually can not do disassociate_ctty() before, say,
	   cgroup_exit(), then we should understand and document the
	   reason.

	2. task_work_add() can have more users in drivers/tty which
	   can be triggered by disassociate_tty() paths. So I think
	   it would be nice to call it before task_work_exit().

2/2 is offtopic and hopefully trivial.

Oleg.
