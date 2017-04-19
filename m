From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201
Date: Wed, 19 Apr 2017 19:28:42 +0200
Message-ID: <87efwob92t.fsf@miraculix.mork.no>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        Aleksander Morgado <aleksander@aleksander.es>
To: Daniele Palmas <dnlplm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40085 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966376AbdDSR2w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 13:28:52 -0400
In-Reply-To: <1491838463-20299-1-git-send-email-dnlplm@gmail.com> (Daniele
        Palmas's message of "Mon, 10 Apr 2017 17:34:23 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniele Palmas <dnlplm@gmail.com> writes:

> as a side note in latest kernels I had troubles with qmi devices
> (e.g. I/O error when using qmicli).
>
> I found your suggestion in libqmi mailing list to revert commit
>
> 833415a3e781a26fe480a34d45086bdb4fe1e4c0
> cdc-wdm: fix "out-of-sync" due to missing notifications

I guess a revert of that commit should be done then..

I have been stalling because I have been hoping to replace it with a
better fix instead of a plain revert. I believe there are several issues
playing badly together here.  That commit was _expected_ to cause
spurious EPIPE errors, which would be translated to EIO if they were
propagated.  But they should be filtered out rightaway, in theory. This
works for me.  I can see the EPIPEs with debugging, but I have never
seen any EIO from read.

And there is the problem: I am unable to reproduce this problem.  I have
previously tested this back and forth with several MDM9200 and MDM9235
generation modems in QMI mode, as well as in MBIM mode.  And also with a
number of other MBIM modems.  Aleksander reported that he could
reproduce the issue using an MDM9x15 generation modem in QMI mode, but
not with any MDM9x00 or MDM9x35 modem.  So I have now tried any way I
can imagine to reproduce the issue with a Sierra Wireless EM7305, which
is the only MDM9x15 modem I have. The firmware is SWI9X15C_05.05.58.00.

But unfortunately the testing is still without "success".  It plain
works for me, every time, using ModemManager, qmicli with or without
proxy, or uqmi.

Would you mind describing in detail how you trigger the EIOs?  What
software and command sequence are you using?  Does it reliably reproduce
the issue, or do you have to try several times?  What modem chipset and
firmware is used?




Bj=C3=B8rn
