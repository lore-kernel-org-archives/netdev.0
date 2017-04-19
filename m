From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Subject: Re: [PATCH 1/1] drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR
 for Telit PID 0x1201
Date: Wed, 19 Apr 2017 20:32:25 +0200
Message-ID: <CAAP7ucL0KLCxVSaO4Vf0LH=T7vRCtm5R2p9VFov+5V0OJF8Xcg@mail.gmail.com>
References: <1491838463-20299-1-git-send-email-dnlplm@gmail.com> <87efwob92t.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87efwob92t.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2017 at 7:28 PM, Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
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

Reliably, as in the second command I sent already showed the issue :/
I meant to try to debug this issue myself a while ago, but got busy
with other stuff, as usual... This is with a Sierra Wireless MC7304
running SWI9X15C_05.05.67.00. If you want, I can give you SSH access
to a system with this modem plugged in, or I can even send you a spare
MC7354, whatever you prefer.

I'm just running --dms-get-operating-mode multiple times, and getting
errors frequently:

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[/dev/cdc-wdm3] Operating mode retrieved:
Mode: 'online'
HW restricted: 'no'

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[19 abr 2017, 20:25:36] -Warning ** Error reading from istream: Error
reading from file descriptor: Input/output error
^[[A^Ccancelling the operation...
error: couldn't create client for the 'dms' service: Operation was cancelle=
d

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[19 abr 2017, 20:25:38] -Warning ** Error reading from istream: Error
reading from file descriptor: Input/output error
^Ccancelling the operation...
error: couldn't create client for the 'dms' service: Operation was cancelle=
d

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[/dev/cdc-wdm3] Operating mode retrieved:
Mode: 'online'
HW restricted: 'no'

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[/dev/cdc-wdm3] Operating mode retrieved:
Mode: 'online'
HW restricted: 'no'

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[/dev/cdc-wdm3] Operating mode retrieved:
Mode: 'online'
HW restricted: 'no'

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[/dev/cdc-wdm3] Operating mode retrieved:
Mode: 'online'
HW restricted: 'no'

aleksander@athena:~/Development/foss/libqmi:(master)$ sudo qmicli -d
/dev/cdc-wdm3 --dms-get-operating-mode
[19 abr 2017, 20:25:52] -Warning ** Error reading from istream: Error
reading from file descriptor: Input/output error
error: couldn't create client for the 'dms' service: CID allocation
failed in the CTL client: Transaction timed out

...

--=20
Aleksander
https://aleksander.es
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
