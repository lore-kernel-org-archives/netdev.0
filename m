From: "Shawn J. Goff" <shawn.goff@accelecon.com>
Subject: Re: qmi-wwan bug
Date: Wed, 24 Oct 2012 18:28:05 -0400
Message-ID: <50886B75.9080408@accelecon.com>
References: <5088385C.1090304@accelecon.com> <943c3dc1-8bc7-4678-a6fd-adc5051f331c@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hub027-nj-6.exch027.serverdata.net ([206.225.167.250]:2092 "EHLO
	hub027-nj-6.exch027.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161258Ab2JXW2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 18:28:17 -0400
In-Reply-To: <943c3dc1-8bc7-4678-a6fd-adc5051f331c@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/24/2012 05:19 PM, Bj=C3=B8rn Mork wrote:
>
> "Shawn J. Goff" <shawn.goff@accelecon.com> wrote:
>
>> I've backported qmi-wwan to 2.6.39 (it's here:
>> https://bitbucket.org/accelecon/linux-at91/changesets), and it mostl=
y
>> works, but I've come across a problem. The modem will sometimes stop
>> responding to any qmi data (but the AT commands on the TTY ports kee=
p
>> working). This only happens when there is significant traffic flowin=
g
>> through the device (downloading a large file) while at the same time=
,
>> AT
>> commands are sent to one of the TTY ports (I first noticed with my o=
wn
>> modem query program, but I can reproduce it using microcom to send
>> "ATI\r" in a loop).
> Using the tty ports should be completely independent of any qmi activ=
ity from the host perspective. I am tempted to claim this indicates a f=
irmware bug.
>
>> I see this problem with different devices from
>> different manufacturers.
> Which still may use pretty much the same firmware, although a little =
less likely.
>
>> I've only made it happen on my kernel - I
>> tried
>> on 3.6.2, but it seems to not happen there.
> Good. But I have a feeling that you switched more than just the kerne=
l. Do you see the issue if you run your backport on the same hardware y=
ou tested 3.6.2 on?

I just tested my 2.6.39 kernel on the same hardware that had 3.6.2; the=
=20
problem is absent there.

>
>   > I've also tried using a
>> similar modem that uses a different driver (sierra-net) and that
>> doesn't
>> have the same problem.
> Well, that is an entirely different firmware application and driver, =
even if the hardware is similar or even identical.

Yes - I wanted to eliminate anything lower (such as usb-net? not sure i=
f=20
qmi-wwan uses that) from being a suspect contributor to the problem.

>
>> When it is in failure, if I try to ping an address, the system sends
>> out
>> several an ARP requests but gets no response. To get the device to
>> respond again, I have to administratively set the wwan interface dow=
n,
>> then up, use libqmi to get the connection going again, then dhcp to =
get
>>
>> an address.
> Which sounds like the connection died. Does QMI work at this point, o=
r is that dead too?

Looks like qmi works. I can do --nas-get-signal-strength and it gives m=
e=20
good numbers. --wds-get-packet-service-status returns "Connection=20
status: '2'"
>
>> I also have some USB traces of the failure and recovery process. I'm
>> not
>> familiar with CDC or QMI, so it's not yet clear to me exactly what's
>> happening, but it looks like the modem just stops sending anything o=
n
>> its QMI endpoint for no reason.
>>
>> How might I dive further into the issue? So far, my next step is to
>> look
>> into CDC and QMI and try to decypher the USB traces. If anyone is
>> interested, I can share a tcpdump or a USB trace.
> I think a test of the backport on the same host hardware you run 3.6.=
2 on would be the best place to start.
>
> Bj=C3=B8rn
Thanks for your help.
