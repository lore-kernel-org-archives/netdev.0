From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: MPLS for Linux kernel
Date: Tue, 22 Nov 2011 14:55:36 +0100
Message-ID: <CAFdo_mXD7by23i38GZHePiHhESpcX66vamBUqHU-fQQFU1RcaA@mail.gmail.com>
References: <CAFdo_mWE8wMB6QJt_DPi9Ou9OiayzV48URDq7KhKf+q8OfP+Gw@mail.gmail.com>
	<4ECA67C6.2080802@dti2.net>
	<20111121.132914.1611617296397809001.davem@davemloft.net>
	<4ECAA41C.9040007@dti2.net>
	<CAFdo_mXzqC_v5OkC6P012gFT_OmRO_yDTA0w96VhV-Lp3Hp7Fw@mail.gmail.com>
	<4ECB95D7.7030702@dti2.net>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:39228 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549Ab1KVNzp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 08:55:45 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 36F786013B
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 14:55:43 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id NQQT6zXvpuus for <netdev@vger.kernel.org>;
	Tue, 22 Nov 2011 14:55:38 +0100 (CET)
Received: from mail-yw0-f46.google.com (mail-yw0-f46.google.com [209.85.213.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id D2771120118
	for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 14:55:37 +0100 (CET)
Received: by ywt32 with SMTP id 32so176265ywt.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 05:55:36 -0800 (PST)
In-Reply-To: <4ECB95D7.7030702@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/22 Jorge Boncompte [DTI2] <jorge@dti2.net>:
> =A0 =A0 =A0 =A0You keep insisting in that you fixed a lot of things, =
but you have provided a
> git tree with just one big commit and say that have taken some of my =
patches on
> it, could you please provide patches on TOP of the sourceforge code f=
or the
> things that are not fixed there?

I insist on that because I did do a lot of things. When I did send you
patch, on TOP of your net-next code, about the most important bug
(stack overflow that was happening when mpls nhlfe entry was built)
that I fixed it was just ignored. Unfortunately I started  fixing MPLS
code without git, and I added your patches manually.

> It seems to me that you have not noticed that while
> fixing bugs I have reworked a lot of code to make it cleaner or simpl=
er, simply
> deleted it and fixed the style.

Yes I saw that

> =A0 =A0 =A0 =A0What's needs to be done, and it's on my TODO list...
>
> =A0 =A0 =A0 =A0The kernel code that is not commented out on the mpls-=
linux code when you build
> the kernel it the shim layer and it's not done on purpose. This code =
was written
> by James to be a generic feature of the networking layer. Now I am no=
t sure that
> it has any value keeping it and am for removing it.

I didn't understand what did You want to say here.

> =A0 =A0 =A0 =A0The other thing that probably I am going to remove is =
the labelspace support. I
> don't see a use for it, and even Cisco doesn't implement it either th=
at I know.

That's 15 min of work, but I think that labelspaces should stay.

> =A0 =A0 =A0 =A0Then we must rework the netlink interface to make it c=
leaner and extensible.

What do you mean by extensible? With my netlink code you can add,
change and delete ilm, nhlfe and xc entries without any problem. What
other could one wish for? As I could see in your code you can't change
ilm, nhlfe and xc entries.

> =A0 =A0 =A0 =A0Check the dst's usages, there has been a lot of change=
s in the core kernel here
> lately and I am not sure if we are using it correctly.

As far I could see you did a great job of using nhlfe as dst entry.
Problem was when you delete nhlfe entry that is referenced with ilm
entry. It shouldn't be allowed to be deleted, or the ilm should change
last instructions from fwd to peek. I did the last thing.
Also there was the problem with neighbor hh_cache, because we are
using nhlfe as dst_entry but I fixed that too.  (hh_cache wouldn't
change when we are sending packets with diferent type (ETH_P_IP and
ETH_P_MPLS_UC))
Also ilm shouldn't be dst_entry. I'm going to change that.

> =A0 =A0 =A0 =A0Check the locking and RCU usage.

There where few problems about that, that I fixed.

BR
Igor
