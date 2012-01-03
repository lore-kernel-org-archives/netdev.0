From: Daniel Halperin <dhalperi@cs.washington.edu>
Subject: Re: skge warning
Date: Tue, 3 Jan 2012 09:27:53 -0800
Message-ID: <CALSq=BZrTr8TdhDR_YphUMtbx5i_+HS346wEG5+xLMStxSJppQ@mail.gmail.com>
References: <CALSq=BbszVSG1y1doetJjM3BO+0XmWk1UyNqv5XViAUdV+xV6Q@mail.gmail.com>
 <CALSq=BZSAuPdjJbp4DxRUAvvLL2-3uc+XW1vA1_kUqbr6CMsHQ@mail.gmail.com> <20120103081012.648953c7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:60357 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136Ab2ACR2O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 12:28:14 -0500
Received: by vbbfc26 with SMTP id fc26so12689097vbb.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 09:28:14 -0800 (PST)
In-Reply-To: <20120103081012.648953c7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> ---------- Forwarded message ----------
>> From: Daniel Halperin <dhalperi@cs.washington.edu>
>> Date: Mon, Jan 2, 2012 at 4:01 PM
>> Subject: skge warning
>> To: netdev@vger.kernel.org
>>
>>
>> I'm using Linus' current branch.
>>
>> drivers/net/ethernet/marvell/skge.c:4046: warning: =91skge_suspend=92
>> defined but not used
>> drivers/net/ethernet/marvell/skge.c:4071: warning: =91skge_resume=92
>> defined but not used
>>
>> It appears to be the use of the wrong CONFIG option. (The code
>> curently uses CONFIG_PM to see whether these functions are used).
>> Here's the relevant section of my .config:
>>
>> #
>> # Power management and ACPI options
>> #
>> # CONFIG_SUSPEND is not set
>> # CONFIG_HIBERNATION is not set
>> CONFIG_PM_RUNTIME=3Dy
>> CONFIG_PM=3Dy
>> CONFIG_PM_DEBUG=3Dy
>> # CONFIG_PM_ADVANCED_DEBUG is not set
>>
>> Thanks,
>> Dan
>
> This usage pattern is common across all network drivers, therefore ei=
ther
> all should change to use CONFIG_PM_SLEEP, or just ignore the extra co=
de.

Thanks, Stephen!

Interestingly, I checked out how the other Ethernet drivers define
their suspend/resume functions via:

% grep SIMPLE_DEV_PM_OPS **/*c
atheros/atl1c/atl1c_main.c:static SIMPLE_DEV_PM_OPS(atl1c_pm_ops,
atl1c_suspend, atl1c_resume);
atheros/atlx/atl1.c:static SIMPLE_DEV_PM_OPS(atl1_pm_ops,
atl1_suspend, atl1_resume);
broadcom/tg3.c:static SIMPLE_DEV_PM_OPS(tg3_pm_ops, tg3_suspend, tg3_re=
sume);
jme.c:static SIMPLE_DEV_PM_OPS(jme_pm_ops, jme_suspend, jme_resume);
marvell/skge.c:static SIMPLE_DEV_PM_OPS(skge_pm_ops, skge_suspend, skge=
_resume);
marvell/sky2.c:static SIMPLE_DEV_PM_OPS(sky2_pm_ops, sky2_suspend, sky2=
_resume);
nvidia/forcedeth.c:static SIMPLE_DEV_PM_OPS(nv_pm_ops, nv_suspend, nv_r=
esume);

and all of them but skge.c use CONFIG_PM_SLEEP instead of CONFIG_PM.
It looks like you hit the nail on the head, but skge.c is the
exception here.

I can submit a patch if you like.

Thanks!
Dan
