From: Daniele Palmas <dnlplm@gmail.com>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR
 for Telit PID 0x1201
Date: Fri, 21 Apr 2017 12:30:20 +0200
Message-ID: <CAGRyCJG2AV9fZEoSWDz4Dh=_Q9Edas1ZiDcfOehz77WEc5OQMw@mail.gmail.com>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com> <87efwob92t.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-usb <linux-usb@vger.kernel.org>,
        Aleksander Morgado <aleksander@aleksander.es>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33573 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037946AbdDUKaV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 06:30:21 -0400
In-Reply-To: <87efwob92t.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bj=C3=B8rn,

2017-04-19 19:28 GMT+02:00 Bj=C3=B8rn Mork <bjorn@mork.no>:
> Daniele Palmas <dnlplm@gmail.com> writes:
>
>> as a side note in latest kernels I had troubles with qmi devices
>> (e.g. I/O error when using qmicli).
>>
>> I found your suggestion in libqmi mailing list to revert commit
>>
>> 833415a3e781a26fe480a34d45086bdb4fe1e4c0
>> cdc-wdm: fix "out-of-sync" due to missing notifications
>
> I guess a revert of that commit should be done then..
>
> I have been stalling because I have been hoping to replace it with a
> better fix instead of a plain revert. I believe there are several issues
> playing badly together here.  That commit was _expected_ to cause
> spurious EPIPE errors, which would be translated to EIO if they were
> propagated.  But they should be filtered out rightaway, in theory. This
> works for me.  I can see the EPIPEs with debugging, but I have never
> seen any EIO from read.
>
> And there is the problem: I am unable to reproduce this problem.  I have
> previously tested this back and forth with several MDM9200 and MDM9235
> generation modems in QMI mode, as well as in MBIM mode.  And also with a
> number of other MBIM modems.  Aleksander reported that he could
> reproduce the issue using an MDM9x15 generation modem in QMI mode, but
> not with any MDM9x00 or MDM9x35 modem.  So I have now tried any way I
> can imagine to reproduce the issue with a Sierra Wireless EM7305, which
> is the only MDM9x15 modem I have. The firmware is SWI9X15C_05.05.58.00.
>
> But unfortunately the testing is still without "success".  It plain
> works for me, every time, using ModemManager, qmicli with or without
> proxy, or uqmi.
>
> Would you mind describing in detail how you trigger the EIOs?  What
> software and command sequence are you using?  Does it reliably reproduce
> the issue, or do you have to try several times?  What modem chipset and
> firmware is used?
>

sorry for the delay, I'm using latest qmicli in master:

danielepa@danielepa-OptiPlex-780:~/development/git/libqmi$ src/qmicli/qmicl=
i -V

qmicli 1.19.0

and I was able to reproduce the issue simply asking for something like
the manufacturer with qmicli.

But I'm currently retrying it and it has become even worse (do not ask
me why...): qmicli returns a transaction timed out error and got
stuck. Only when detaching the USB cable qmicli exits.

danielepa@danielepa-OptiPlex-780:~/development/git/libqmi$ sudo
src/qmicli/qmicli -d /dev/cdc-wdm0 --dms-get-manufacturer
[21 apr 2017, 12:15:33] -Warning ** [/dev/cdc-wdm0] requested auto
mode but no MBIM QMUX support available
error: couldn't create client for the 'dms' service: CID allocation
failed in the CTL client: Transaction timed out

I'm not sure I'm seeing here only problems related to your commit, but
reverting the commit makes things to work again.

The modem is a Telit LE920A4. I will try to collect more debug info.

Thanks,
Daniele

>
>
>
> Bj=C3=B8rn
>
