From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] bridge: Forward EAPOL Kconfig option BRIDGE_PAE_FORWARD
Date: Fri, 1 Jul 2011 16:58:56 +0200
Message-ID: <BANLkTimjnP87CAA7JVAe5hqeP08Hd7766g@mail.gmail.com>
References: <BANLkTikDqjErqBmfwrN6SJPgPjmmMfJw7g@mail.gmail.com>
 <20110628185811.GA2121496@jupiter.n2.diac24.net> <BANLkTi=goXU4SpP6dxX9C+YeLcVMEkcKHw@mail.gmail.com>
 <20110628202200.GB2121496@jupiter.n2.diac24.net> <BANLkTim1owW7iMS3hgKhm7DzTzE4X-jxHA@mail.gmail.com>
 <20110628210434.GD2121496@jupiter.n2.diac24.net> <BANLkTikN_TPPcyywVT5W9CrGAFJX8qQiyQ@mail.gmail.com>
 <20110628214637.GE2121496@jupiter.n2.diac24.net> <BANLkTi=4-xYNyaBOzeL04VioK8D0Q8secg@mail.gmail.com>
 <20110629163423.1d73b0ef@nehalam.ftrdhcpuser.net> <20110701101625.GB3988422@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Nick Carter <ncarter100@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38291 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab1GAO7R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 10:59:17 -0400
Received: by qwk3 with SMTP id 3so1635231qwk.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 07:59:16 -0700 (PDT)
In-Reply-To: <20110701101625.GB3988422@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/7/1 David Lamparter <equinox@diac24.net>:
> On Wed, Jun 29, 2011 at 04:34:23PM -0700, Stephen Hemminger wrote:
>> The problem is that the damn 802.1 committees keep loading up protoc=
ols
>> on the same multicast address range. Trying to solve a design commit=
tee
>> problem in the kernel is not going to make anybody happy.
>>
>> I am happy with the simple solution of:
>> =C2=A0 no STP =3D=3D Hub
>> =C2=A0 STP =C2=A0 =C2=A0=3D=3D Bridge
>> These are both well know configurations and are blessed by standards=
=2E
>
> I agree, that is how we should behave by default, and we'll match mos=
t
> admin's expectations.
>
> Regarding multicast groups, I would summarise like this:
> 1. any multicast gets forwarded by default,
> =C2=A02. unless it is 01:80:c2:00:00:01 or :02 (pause/bonding)
> =C2=A0 =C2=A0(this rule applies regardless of STP state)
> =C2=A03. if STP is on:
> =C2=A04. 01:80:c2:00:00:00 (STP) never gets forwarded
> =C2=A05. 01:80:c2:00:00:03-0f don't get forwarded by default
>
> What we can do is add a switch to disable the #5 rule. The way I see =
it
> is that that switch would remove an exception from the rule and turn =
it
> back to the default #1; that's acceptable for making a new knob in my
> eyes.
>
> (Adding an 802.1X knob would be an exception to the exception for me,
> which is why I'm against it.)
>
> I'll cook up a patch in a few minutes, we really need to get rule #2
> right anyway. We _MUST_NOT_ pass bonding frames in any case, but we
> currently do that if STP is off. (cf. my earlier patch 1/2)

If you use linux box as a (invisible) L2 network tap, then you want to
pass everything in the hub mode (including LACP/whatever).

Best Regards,
Micha=C5=82 Miros=C5=82aw
