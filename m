From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 0/10] af_unix: add multicast and filtering features to AF_UNIX
Date: Fri, 2 Mar 2012 10:39:24 +0200
Message-ID: <CABBYNZLwHKd5srzYYzWNL-iaeuH1K31824pY_bjRSbSLkv0QtA@mail.gmail.com>
References: <1330604802.2465.43.camel@edumazet-laptop>
	<20120301.154415.1692328508436381200.davem@davemloft.net>
	<CABBYNZJ-xxQXAx+ecrkVLqmWFaUVqLcQLj0Jxa3McSLnkLJSJw@mail.gmail.com>
	<20120301.170848.432407217191581288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, javier.martinez@collabora.co.uk,
	rodrigo.moya@collabora.co.uk, javier@collabora.co.uk,
	lennart@poettering.net, kay.sievers@vrfy.org,
	alban.crequy@collabora.co.uk, bart.cerneels@collabora.co.uk,
	sjoerd.simons@collabora.co.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120301.170848.432407217191581288.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Fri, Mar 2, 2012 at 12:08 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
> Date: Fri, 2 Mar 2012 00:01:40 +0200
>
>> I don't think you understood the problem, we want something that sca=
le
>> for less powerful devices, why do you think Android have all the
>> trouble to create binder?
>
> So our protocol stack is so cpu hungry compared to AF_UNIX that it's
> unusable on low power devices?

I never said unusable, it will drastically increase latency of message
which translates in less responsive applications.

> I can't take you seriously if you say this after showing us the
> thousands of lines of code you guys think we should add to the AF_UNI=
X
> socket layer.

But what you are suggesting transforms dbus-daemon in a ip router just
to do multicast, actually how many lines of code do you think we gonna
need to implement that? Probably much more than adding this much to
the kernel and is not necessarily useful for anybody else.

Like I said before there is many projects using AF_UNIX as IPC
transport, the documentation actually induces people to use for this
purpose, and many would benefit from being able to do multicast.

Btw Im not involved with the implementation and perhaps it need some
extra work, but IMO the idea is very useful.

>> Besides what is really the point in having AF_UNIX if you can't use
>> for what it is for?
>
> Because it doesn't have the handful of extra features you absolutely
> require of it.

You mean multicast, that is one and only, with many implementation
details with that I agree.

> AF_UNIX is a complicated socket layer which is already extremely hard
> to maintain. =A0We're still finding bugs in it even after all these
> years, and that's without adding major new functionality.

I understand your concern, this could make things even more unstable,
but in the other hand hacking support of multicast to loopback would
also mess with AF_INET, so in one way or the other the kernel will
have to be involved.

Also note that AF_UNIX has very key features of an efficient IPC, like
the ability to pass fd to another process with SCM_RIGHTS.

--=20
Luiz Augusto von Dentz
