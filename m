From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: the side effect of using copy skb instead of skb_clone in cdc ncm/mbim driver
Date: Wed, 09 Jul 2014 18:01:45 +0200
Message-ID: <87zjgih66u.fsf@nemi.mork.no>
References: <CAOa2BBy4t_17J7G5bBpAZZpBWZYh+Cpc6Fn4u+9cV98M8CZ5gw@mail.gmail.com>
	<87y4w4jprx.fsf@nemi.mork.no>
	<CAOa2BBwVxcC_WoAqExRgEX57BwkikOL_sOBnjus+udNzVB0zqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jim_baxter@mentor.com, Alexey Orishko <alexey.orishko@gmail.com>,
	netdev@vger.kernel.org, zhao.ming9@zte.com.cn
To: joey ming <joey.zming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40862 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755407AbaGIQB4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 12:01:56 -0400
In-Reply-To: <CAOa2BBwVxcC_WoAqExRgEX57BwkikOL_sOBnjus+udNzVB0zqw@mail.gmail.com>
	(joey ming's message of "Wed, 9 Jul 2014 22:55:05 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[didn't notice earlier, but Alexey's address was wrong - I fixed it on
this reply]

joey ming <joey.zming@gmail.com> writes:

> thanks for your reply.
> from my test results, perhaps the ncm protocol is the same efficiency=
 with
> cdc-ecm. But Alexey(alexey.orishko@stericsson.com) said his experimen=
t two
> years ago:"One real-world example was modem for 21+6Mbit/s what used =
100%
> CPU with ECM responsible for approx. 40% of the MIPS used. Using NCM
> instead CPU was only at approx. 65% utilization. Which allowed multip=
le
> other functions to be added and significantly increased the usability=
 and
> value of the modem". I don't know why the test result was differ so l=
arge.
> Is that correct that cdc-ncm is effctive than cdc-ecm for low speed d=
evice
> but not for high speed device?

Alexey's results were on modem hardware, and I am guessing the OS wasn'=
t
Linux.  I have no doubt that you can increase efficiency if you can tak=
e
a fixed size big NCM buffer, and make the radio interface write packets
directly into it using the alignment of your choice, before you just
give the whole buffer to a USB controller.  You mostly don't have to
involve the CPU at all.  So NCM is probably a great win for the modems,
and you are right: That is likely why this aggregating protocol was
invented.

But little of this is applicable to the typical Linux implementation,
whether it runs on a host or a device.  Big USB buffers do not help muc=
h
on the USB controllers, and they are just a hassle other places because
it's difficult to pass partial buffers around.

And I think modem hardware now has become so much more powerful that th=
e
same applies to it as well.


Bj=C3=B8rn
