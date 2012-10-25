From: "Shawn J. Goff" <shawn.goff@accelecon.com>
Subject: Re: qmi-wwan bug
Date: Thu, 25 Oct 2012 06:19:11 -0400
Message-ID: <5089121F.7080001@accelecon.com>
References: <5088385C.1090304@accelecon.com> <943c3dc1-8bc7-4678-a6fd-adc5051f331c@email.android.com> <50886B75.9080408@accelecon.com> <87a9vb579x.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hub027-nj-2.exch027.serverdata.net ([206.225.167.246]:58162
	"EHLO hub027-nj-2.exch027.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935163Ab2JYKTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 06:19:13 -0400
In-Reply-To: <87a9vb579x.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2012 03:40 AM, Bj=C3=B8rn Mork wrote:
> "Shawn J. Goff" <shawn.goff@accelecon.com> writes:
>> On 10/24/2012 05:19 PM, Bj=C3=B8rn Mork wrote:
>>> "Shawn J. Goff" <shawn.goff@accelecon.com> wrote:
>>>
>>>> I've only made it happen on my kernel - I
>>>> tried
>>>> on 3.6.2, but it seems to not happen there.
>>> Good. But I have a feeling that you switched more than just the
>>> kernel. Do you see the issue if you run your backport on the same
>>> hardware you tested 3.6.2 on?
>> I just tested my 2.6.39 kernel on the same hardware that had 3.6.2;
>> the problem is absent there.
> As I suspected.  Then I believe this issue is more likely related to
> your hardware platform and/or its other lower layer drivers, and not =
to
> the backported qmi_wwan driver directly.
>
> Maybe an obscure firmware issue related to timing or other difference=
s?
> That is going to be difficult to track down, if it really is the caus=
e.

That's what I figured when I coudn't reproduce it on the other hardware=
=2E=20
The first thing I'm going to do is check the power - I noticed the USB=20
+5V supply can drop to around 4.8V when the modem is under load. I'll=20
apply a bench power supply and see if that fixes things.

>>>    > I've also tried using a
>>>> similar modem that uses a different driver (sierra-net) and that
>>>> doesn't
>>>> have the same problem.
>>> Well, that is an entirely different firmware application and driver=
,
>>> even if the hardware is similar or even identical.
>> Yes - I wanted to eliminate anything lower (such as usb-net? not sur=
e
>> if qmi-wwan uses that) from being a suspect contributor to the
>> problem.
> Yes, that is useful.  You are perfectly right that most of the host s=
ide
> drivers are common. Both sierra_net and qmi_wwan are usbnet minidrive=
rs,
> and almost all network device functionality is served by the shared
> usbnet framework.  So this test pretty much eliminates the host USB
> stack.
>
> Which IMHO points to the firmware implementation as the major
> difference.
>
>>>> When it is in failure, if I try to ping an address, the system sen=
ds
>>>> out
>>>> several an ARP requests but gets no response. To get the device to
>>>> respond again, I have to administratively set the wwan interface d=
own,
>>>> then up, use libqmi to get the connection going again, then dhcp t=
o get
>>>>
>>>> an address.
>>> Which sounds like the connection died. Does QMI work at this point,=
 or is that dead too?
>> Looks like qmi works. I can do --nas-get-signal-strength and it give=
s
>> me good numbers. --wds-get-packet-service-status returns "Connection
>> status: '2'"
> Ah, interesting.  Then we only need to find out where the bulk URBs e=
nd
> up.
>
> I would have tried to enable what I could of USB and usbnet debugging=
 to
> see if there are any hints there.  A usbmon trace may also show the
> problem.  I don't know.  But in any case, I believe this is a USB
> problem and probably not too interesting for netdev...
After power, I'll move on to enabling whatever USB debugging I can find=
=2E
Thanks!
