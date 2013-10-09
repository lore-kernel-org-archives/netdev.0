From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: MBIM device refusing to be enabled
Date: Wed, 09 Oct 2013 12:29:43 +0200
Message-ID: <87hacqzqi0.fsf@nemi.mork.no>
References: <1381309180.3464.2.camel@linux-fkkt.site>
	<871u3u21zz.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53399 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735Ab3JIK3w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 06:29:52 -0400
In-Reply-To: <871u3u21zz.fsf@nemi.mork.no> (=?utf-8?Q?=22Bj=C3=B8rn?=
 Mork"'s message of "Wed, 09
	Oct 2013 12:05:20 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bj=C3=B8rn Mork <bjorn@mork.no> writes:

> Oliver Neukum <oliver@neukum.org> writes:
>
>> I have a device which the kernel and MM (1.0) identify as MBIM.
>> I can transfer the PIN, but the device refuses to be enabled.
>> Any idea?
>
> [..]
>
>> 2013-10-09T10:49:49.930237+02:00 linux-3m4i ModemManager[566]:
>> [/dev/cdc-wdm0] Received message...#012>>>>>> RAW:#012>>>>>>   lengt=
h =3D
>> 56#012>>>>>>   data   =3D
>> 03:00:00:80:38:00:00:00:13:00:00:00:01:00:00:00:00:00:00:00:A2:89:CC=
:33:BC:BB:8B:4F:B6:B0:13:3E:C2:AA:E6:DF:03:00:00:00:00:00:00:00:08:00:0=
0:00:01:00:00:00:00:00:00:00
>> 2013-10-09T10:49:49.930545+02:00 linux-3m4i ModemManager[566]:
>> [/dev/cdc-wdm0] Received message (translated)...#012>>>>>>
>> Header:#012>>>>>>   length      =3D 56#012>>>>>>   type        =3D
>> command-done (0x80000003)#012>>>>>>   transaction =3D 19#012>>>>>>
>> Fragment header:#012>>>>>>   total   =3D 1#012>>>>>>   current =3D
>> 0#012>>>>>> Contents:#012>>>>>>   status error =3D
>> 'None' (0x00000000)#012>>>>>>   service      =3D
>> 'basic-connect' (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)#012>>>>>>   c=
id
>> =3D 'radio-state' (0x00000003)
>
> It's a bit difficult to read these logs, but decoding the raw data
> results in:
>
> MBIM_MESSAGE_HEADER
>   MessageType:  0x80000003 (MBIM_COMMAND_DONE)
>   MessageLength:        56
>   TransactionId:        19
> MBIM_FRAGMENT_HEADER
>   TotalFragments:       0x00000001
>   CurrentFragment:      0x00000000
> BASIC_CONNECT (a289cc33-bcbb-8b4f-b6b0-133ec2aae6df)
> MBIM_CID_RADIO_STATE (3)
> MBIM_STATUS_SUCCESS (0)
> InformationBuffer [8]:
>   HwRadioState: on
>   SwRadioState: off
>
> Which either means that the radio is disabled using rfkill, or that
> there is a problem with the platform rfkill driver for your laptop.
> In any case, this is the reason you cannot enable the modem.
>
> Does "rfkill list" confirm that the radio is disabled?  Can you chang=
e
> it?

Sorry, that was nonsense.  rfkill would only affect the HwRadioState.

Looking at the commands following this message, it appears that MM
correctly attempts to enable the SwRadioState but fails.  I don't know
why.


Bj=C3=B8rn
