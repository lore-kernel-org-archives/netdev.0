From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: [linux-pm] intermittent suspend problem again
Date: Sun, 29 Nov 2009 11:12:13 +0100
Message-ID: <873a3x4p36.fsf__10879.4457432397$1259585919$gmane$org@tac.ki.iif.hu>
References: <87fx93pwv2.fsf@tac.ki.iif.hu> <200911182313.14092.rjw@sisk.pl>
	<87d4324gp7.fsf@tac.ki.iif.hu> <200911290129.25505.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pm@lists.linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:46221 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbZK3M6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2009 07:58:20 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.69)
	(envelope-from <wferi@tac.ki.iif.hu>)
	id 1NF5ph-0005xs-4t
	for netdev@vger.kernel.org; Mon, 30 Nov 2009 13:58:25 +0100
In-Reply-To: <200911290129.25505.rjw@sisk.pl> (Rafael J. Wysocki's message of
	"Sun, 29 Nov 2009 01:29:25 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Rafael J. Wysocki" <rjw@sisk.pl> writes:

> On Saturday 28 November 2009, Ferenc Wagner wrote:
>> "Rafael J. Wysocki" <rjw@sisk.pl> writes:
>> 
>>> On Wednesday 18 November 2009, Ferenc Wagner wrote:
>>>
>>>> Ferenc Wagner <wferi@niif.hu> writes:
>>>> 
>>>>> Since I've instrumented s2disk and the hibernation path, no freeze
>>>>> happened during hibernating the machine.
>>>> 
>>>> Not until I removed the delays from hibernation_platform_enter(), which
>>>> were put there previously to get step-by-step feedback.  Removing them
>>>> again resulted in a freeze in short course, maybe just two hibernations
>>>> later.  The instrumentation shows it stuck in dpm_suspend_start(PMSG_HIBERNATE).
>>>> Does it mean that some device driver is at fault?
>>>
>>> A driver or one of the platform hooks.
>>>
>>>> I'll check if it always fails at the same point (although tracing into
>>>> dpm_suspend_start isn't pure fun because of the multitude of devices it
>>>> loops over).  Is there any way to get printk output from that phase?
>>>
>>> Compile with CONFIG_PM_VERBOSE (it does mean exactly that).
>> 
>> The last message now was:
>> 
>> e100: 0000:02:08.0: hibernate, may wakeup
>> 
>> Looks like hibernating the e100 driver is unstable.
>
> Can you verify that by trying to hibernate without the e100 driver?

Not really, as I still can't reliable reproduce the issue.  Since I'm
running with suspend loglevel = 8, it's happened only twice (in a row),
with seemingly exact same console output.  Some earlier freezes also
happened in dpm_suspend_start, at least.  However, I can certainly add
e100 to SUSPEND_MODULES under /etc/pm/config.d, and continue running
with that.  Or I can try stress-testing the module, but not sure, how.
Interestingly, git log v2.6.31.. -- e100.c is tiny, but 8fbd962e affects
the suspend/resume routines through e100_up.  This could explain the
timing-sensitive nature of the issue.  I took the liberty to change the
Cc list, maybe linux-netdev can lend us a hand.
-- 
Regards,
Feri.
