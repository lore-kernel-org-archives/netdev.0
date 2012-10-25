From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: qmi-wwan bug
Date: Thu, 25 Oct 2012 09:40:26 +0200
Message-ID: <87a9vb579x.fsf@nemi.mork.no>
References: <5088385C.1090304@accelecon.com>
	<943c3dc1-8bc7-4678-a6fd-adc5051f331c@email.android.com>
	<50886B75.9080408@accelecon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: "Shawn J. Goff" <shawn.goff@accelecon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42004 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754979Ab2JYHkb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 03:40:31 -0400
In-Reply-To: <50886B75.9080408@accelecon.com> (Shawn J. Goff's message of
	"Wed, 24 Oct 2012 18:28:05 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Shawn J. Goff" <shawn.goff@accelecon.com> writes:
> On 10/24/2012 05:19 PM, Bj=C3=B8rn Mork wrote:
>> "Shawn J. Goff" <shawn.goff@accelecon.com> wrote:
>>
>>> I've only made it happen on my kernel - I
>>> tried
>>> on 3.6.2, but it seems to not happen there.
>>
>> Good. But I have a feeling that you switched more than just the
>> kernel. Do you see the issue if you run your backport on the same
>> hardware you tested 3.6.2 on?
>
> I just tested my 2.6.39 kernel on the same hardware that had 3.6.2;
> the problem is absent there.

As I suspected.  Then I believe this issue is more likely related to
your hardware platform and/or its other lower layer drivers, and not to
the backported qmi_wwan driver directly.

Maybe an obscure firmware issue related to timing or other differences?
That is going to be difficult to track down, if it really is the cause.

>>   > I've also tried using a
>>> similar modem that uses a different driver (sierra-net) and that
>>> doesn't
>>> have the same problem.
>>
>> Well, that is an entirely different firmware application and driver,
>> even if the hardware is similar or even identical.
>
> Yes - I wanted to eliminate anything lower (such as usb-net? not sure
> if qmi-wwan uses that) from being a suspect contributor to the
> problem.

Yes, that is useful.  You are perfectly right that most of the host sid=
e
drivers are common. Both sierra_net and qmi_wwan are usbnet minidrivers=
,
and almost all network device functionality is served by the shared
usbnet framework.  So this test pretty much eliminates the host USB
stack.

Which IMHO points to the firmware implementation as the major
difference.

>>> When it is in failure, if I try to ping an address, the system send=
s
>>> out
>>> several an ARP requests but gets no response. To get the device to
>>> respond again, I have to administratively set the wwan interface do=
wn,
>>> then up, use libqmi to get the connection going again, then dhcp to=
 get
>>>
>>> an address.
>> Which sounds like the connection died. Does QMI work at this point, =
or is that dead too?
>
> Looks like qmi works. I can do --nas-get-signal-strength and it gives
> me good numbers. --wds-get-packet-service-status returns "Connection
> status: '2'"

Ah, interesting.  Then we only need to find out where the bulk URBs end
up.

I would have tried to enable what I could of USB and usbnet debugging t=
o
see if there are any hints there.  A usbmon trace may also show the
problem.  I don't know.  But in any case, I believe this is a USB
problem and probably not too interesting for netdev...


Bj=C3=B8rn
