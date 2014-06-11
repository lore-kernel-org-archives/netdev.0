From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: cdc-wdm: unable to connect after suspend
Date: Wed, 11 Jun 2014 10:01:59 +0200
Message-ID: <87lht350y0.fsf@nemi.mork.no>
References: <ln6m4k$q49$1@ger.gmane.org> <874mzt55kz.fsf@nemi.mork.no>
	<53971171.5070001@flokli.de> <539712BA.5010004@flokli.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, modemmanager-devel@lists.freedesktop.org
To: Florian Klink <flokli@flokli.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54704 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755590AbaFKICK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 04:02:10 -0400
In-Reply-To: <539712BA.5010004@flokli.de> (Florian Klink's message of "Tue, 10
	Jun 2014 16:14:18 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46lorian Klink <flokli@flokli.de> writes:
> Am 10.06.2014 16:08, schrieb Florian Klink:
>> Am 10.06.2014 14:09, schrieb Bj=C3=83=C5=BErn Mork:
>>> Florian Klink <flokli@flokli.de> writes:
>>>
>>>> Hi,
>>>>
>>>> I recently bought a notebook (Fujitsu Lifebook T904) with integrat=
ed
>>>> 3G/4G modem (Sierra Wireless EM7305) thats powered by the cdc-wdm =
driver.
>>>>
>>>> It works without any problems on a fresh bootup using Networkmanag=
er.
>>>>
>>>> However, after putting the notebook into standby and waking up aga=
in,
>>>> I'm unable to get a connection (always reproducible, not signal qu=
ality
>>>> related).
>>>
>>> Does it work again if you restart NetworkManager and ModemManager a=
t
>>> this point?
>>=20
>> Nope. ModemManager gets confused completely and drops the modem out =
of
>> the list of connections:
>>=20
>> ModemManager[3067]: <warn>  Couldn't find support for device at
>> '/sys/devices/pci0000:00/0000:00:19.0': not supported by any plugin
>> ModemManager[3067]: <warn>  Couldn't find support for device at
>> '/sys/devices/pci0000:00/0000:00:1c.3/0000:03:00.0': not supported b=
y
>> any plugin
>> ModemManager[3067]: [/dev/cdc-wdm1] Queried max control message size=
: 4096
>> ModemManager[3067]: [/dev/cdc-wdm1] No transaction matched in receiv=
ed
>> message

Ah, OK.  Then I obviously guessed wrong.  MM and the firmware does not
agree on the current transaction sequence. I'm not sure why. The modem
is sending unexpected messages, and I assume MM doesn't get the answers
it is looking for.  This could be caused by the driver cancelling the
interrupt URB at an "inconvenient time" for the firmware.  But I haven'=
t
seen issues like that with the Qualcomm based Sierra modems before.

And you get into this state consistently on every suspend+resume?=20

It would be useful to know which unexpeced messages we receive (errors?
same message all over? older queued up messages being played back with
unexpected delay?)  Any chance you can enable libmbim + ModemManager
debugging to get the MBIM message dumps?


>>> Does it help to do
>>>
>>>  echo  0 >/sys/bus/usb/devices/x-y/power/persist
>>>
>>> prior to suspending the notebook?  You'll have to replace "x-y" wit=
h the
>>> correct USB bus and port number.  You can find this in e.g. the dme=
sg
>>> output.  For example, if your log shows:
>>>
>>>   qmi_wwan 2-4:1.8: cdc-wdm0: USB WDM device
>>>
>>> then x-y =3D 2-4.
>>=20
>> dmesg shows "cdc_mbim 1-6:2.12: cdc-wdm1: USB WDM device", so I did =
echo
>> 0 > /sys/bus/usb/devices/1-6/power/persist.
>>=20
>> However, after a suspend/resume cycle, connecting didnt work either.
>> Errors were the same as without persist =3D 0.

Yes, my initial guess was wrong, so this is not the problem.

>> dmesg doesn't really show an error message from the modem. Seems lik=
e it
>> also has an issue resuming "Bus 001 Device 006: ID 0483:91d1
>> STMicroelectronics", but this shouldn't cause the problems with the =
modem...
>
> I attached the dmesg output, probably there's till something interest=
ing
> inside ;-)

Thanks.  I wasn't expecting any errors there (I still don't think there
is any real error here from the drivers point of view), but I wanted to
see whether the modem is disconnected and rediscovered or just plainly
suspended.

But???  I cannot find anything related to the modem device in that log?
Not even anything mentioning the "1-6" USB port.



Bj=C3=B8rn
