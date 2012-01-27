From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netns: fix net_alloc_generic()
Date: Thu, 26 Jan 2012 22:54:07 -0800
Message-ID: <m1k44d8wkw.fsf@fess.ebiederm.org>
References: <CA+1xoqe+Qa1OByj7z7XzAPG_g9+BmNj9NPZR=_5b_MTEmc9Chw@mail.gmail.com>
	<1327523631-3480-1-git-send-email-sjur.brandeland@stericsson.com>
	<1327574498.2500.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4F212E7E.2040801@parallels.com>
	<1327575108.2500.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<m1zkdacbsx.fsf@fess.ebiederm.org>
	<1327644547.2919.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	"levinsasha928\@gmail.com" <levinsasha928@gmail.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davej\@redhat.com" <davej@redhat.com>,
	"sjurbren\@gmail.com" <sjurbren@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327644547.2919.11.camel@edumazet-laptop> (Eric Dumazet's
	message of "Fri, 27 Jan 2012 07:09:07 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Le jeudi 26 janvier 2012 =C3=A0 14:57 -0800, Eric W. Biederman a =C3=A9=
crit :
>
>> It is not a chicken and egg problem.  It is a bug in caif.
>> caif is claiming to be a network device when it is acting as a subsy=
tem.
>> That means it is being initialized too late.
>>=20
>
> Ah ok !
>
>> Untested but this should trivially fix the problem, and a bunch
>> of others of the same ilk.
>>=20
>
> Hmm, please refrain from using "trivially" or "trivial", you're not
> fooling anyone.

All I meant is that the change was trivial.

> Truth is this netns layer is horribly complex, since this CAIF bug
> needed no more than four patch attempts and lastly your own work befo=
re
> finding the root cause.

As for the complexity I don't know that it is noticeably worse than the
initialization complexity of the network stack in general.

I do think that it is non-obvious that serious initialization ordering
problems can be caused by such a small difference.  The non-locality
and of cause and effect, combined with unfamiliarity of the code seems
to be what hides problems like this.

Once you know that initialization ordering problems tend to registering
the wrong way.  Aka as a device instead of a subsys the solution to
problems like this tend to jump out at you.

Now the common plumbing in net/core/net_namespace.c does count as
complex.  The fact we missed such an obvious optimization opportunity
for so long seems to confirm that.

I am open for ideas on how to simply things. =20

Eric
