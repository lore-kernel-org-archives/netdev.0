From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Mon, 8 Sep 2008 17:20:43 -0300
Message-ID: <20080908172043.0d25a427@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:19914 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473AbYIHUUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 16:20:52 -0400
Received: by an-out-0708.google.com with SMTP id d40so293742and.103
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 13:20:51 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Sep 2008 13:27:43 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> It could well be possible, accept seems to call schedule_timeout if=20
> nothing is immediately available (but I don't know well enough what=20
> end up being hrtimer'ed when you enable them and what will not)...=20
> Anyway, how long did you test for that to confirm it?

	It has been five days since I disable high resolution timer and
have not got any problems anymore.

> Does this explain the 2.6.24->2.6.25 change in behavior as well (ie.,=
=20
> did they got enabled there)?

	Well, as far as I know, high res timer related, what changed
in 2.6.25 is the following:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D8f4d37ec073c17e2d4aa8851df5837d798606d6f

	(although if I disable dynticks, the problem persists)

	Although in 2.6.24 we already had, for example the x86-32/64
arch reunification and I don't know if it has anything to do with my
problem in 2.6.25... just some thoughts... I wrote that because the
problem doesn't happen in 32 bit machines, but only in x86_64...

	Of course I'm not saying for sure that the high res timer is
causing this. Maybe, as you said before, the problem is much more
complex and realy don't know what in fact uses high res timer.

	Anyway, I'll leave high res timer disabled for now until we
discover something new.
=09
--=20
