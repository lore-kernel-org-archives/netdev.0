From: Thomas Elliott <tommygunsster@gmail.com>
Subject: Re: e1000e er32(TIMINCA) value returned 0 Virtual Machiens
Date: Sun, 7 Feb 2016 17:41:58 -0500
Message-ID: <CAHC3ikmXEyuEyVp-2X8h2FXdXx2AaOuvUDBvW3T1OaNAPNAOpA@mail.gmail.com>
References: <CAHC3ikmsH5KikrSMtCx+DWvnJyuhZ48JZGKK7MiYnLMV6wc=Kw@mail.gmail.com>
	<20160207220403.GA13888@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:35648 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbcBGWl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:41:59 -0500
Received: by mail-yk0-f176.google.com with SMTP id r207so81199832ykd.2
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:41:59 -0800 (PST)
In-Reply-To: <20160207220403.GA13888@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know how TIMINCA is getting cleared to zero.  All I know is
this situation apparently occurs with VM's.  And while I do agree a
fix from the VM guys would be necessary, this simple one liner fixes
it, because SOMETHING is causing it to get set to/as/reset to zero.

If there's nothing to be done fine, I just thought a simple one line
that checks the incvalue BEFORE it panics a kernel would be useful.

I provided what I've been able to find and a potential solution to
what ailed some of what I've experienced.  I don't understand why it's
happening, I just know that it IS happening.

On Sun, Feb 7, 2016 at 5:04 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Sun, Feb 07, 2016 at 10:28:48AM -0500, Thomas Elliott wrote:
>> task: ffff88003e4b8000 ti: ffff88003e4c0000 task.ti: ffff88003e4c0000
>> RIP: 0010:[<ffffffff8172817a>]  [<ffffffff8172817a>] 0xffffffff8172817a
>> RSP: 0000:ffff88003e4c3cf0  EFLAGS: 00010246
>> RAX: 0000000000000000 RBX: ffff880038cdf640 RCX: 0000000000000000
>> RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff880038cdf628
>> RBP: ffff880038cdf628 R08: 0000000000000032 R09: 0000000000000000
>> R10: 00000007ffffffff R11: 00000000070f8406 R12: 142fe5b9982e5912
>> R13: ffff880038cdcc38 R14: 0000000000000000 R15: 0000000000000000
>> FS:  0000000000000000(0000) GS:ffff88003ea00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> CR2: 0000000000000000 CR3: 0000000001f74000 CR4: 00000000000006b0
>> Stack:
>>  ffffffff81071eca ffff880038cdc780 0000000000000000 0000000000000000
>>  ffffffff8172ec3c 01a000002252a32c ffff880038cdc780 ffff880038cdcc38
>>  0000000000008000 ffff880038cdcc38 0000000000000003 ffff880038cdc000
>> Call Trace:
>>  [<ffffffff81071eca>] ? 0xffffffff81071eca
>
> Are you sure about the which funtion throws this bug?  KALLSYMS?
>
>> A proposed fix is to check if TIMINCA is returned with 0, as division
>> by 0 seems to be the reasoning for the panic altogether.
>
> Divide by zero is indeed a bug, but the question is, why does this
> happen?
>
>> As I understand this isn't a "normal" situation for physical boards,
>> it still seems a bit rought to always expect physical boards will
>> NEVER return 0 for this situation.
>
> That register is set to a non-zero value in e1000e_config_hwtstamp,
> which is called from e1000_probe via e1000e_reset.  So it appears to
> be initialized.
>
>> All this does is check if the value of incvalue is 0 and return systim
>> if it is.  This means you're not going to run into a situation and is
>> just plain, in my opinion, better error checking.  A single line of
>> code that allows VMs, and possibly future hardware that might present
>> this issue, from panicking over something that is so simple a check.
>
> This is only papering only the problem.  We need to know how TIMINCA
> is getting cleared to zero.
>
> Thanks,
> Richard



-- 
V/R
Thomas G. Elliott
247 Sugar Hill Road
Crown Point, NY 12928
Home: 518-907-4327 (Preferred)
Cell: 518-335-8682
E-mail: tommygunsster@gmail.com (Preferred)
Alt: thomas@mastacontrola.com
Alt2: thomas.elliott@mastacontrola.com
