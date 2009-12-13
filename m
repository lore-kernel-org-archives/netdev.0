From: Michael Stone <michael@laptop.org>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Sun, 13 Dec 2009 08:44:25 -0500
Message-ID: <20091213134425.GA4777@heat>
References: <200912131032.24251.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200912131032.24251.remi@remlab.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi,                                                                =
                                                                       =
                                                                       =
                                                =20
> You explicitly mention the need to connect to the X server over local=
 sockets.
> But won't that allow the sandboxed application to send synthetic even=
ts to any
> other X11 applications?=20

X11 cookie authentication and socket ownership+permissions effectively =
control
access to the X server by local processes. Thus, as an isolation author=
, I may
easily grant my isolated process any of:

   a) full access to the main X server=20
   b) some access to a nested X server (like a Xephyr) which I'm using =
to do
      some event filtering
   c) no access to any X server by witholding thec cookies or by changi=
ng the
      permissions on the X socket to be more restrictive

with existing techniques.

> Hence unless the whole X server has restricted network access, this s=
eems a
> bit broken?=20

Not broken for the reasons I mentioned above. However, using this rlimi=
t to
disable fresh network access for the whole X server actually sounds lik=
e a
rather nice idea; thanks for suggesting it.

> D-Bus, which also uses local sockets, will exhibit similar issues,=20

Absolutely. However, D-Bus, like X, already has strong authentication
mechanisms in place that permit me to use pre-existing Unix discretiona=
ry=20
access control to limit what communication takes place. More specifical=
ly, I can=20

   a) tell D-Bus to use a file-system socket and change the credentials=
 on that
      socket

   b) use cookies to authenticate incoming connections

   c) explicitly tell D-Bus what users and groups may connect via confi=
guration
      files

   d) explicitly tell D-Bus what users and groups may send and receive =
which
      messages via configuration files

> as will any unrestricted IPC mechanism in fact. I am not sure if rest=
ricting
> network access but not other file descriptors makes that much sense..=
=2E? Then
> again, I'm not entirely clear what you are trying to solve.

Inadequately access-controlled IPC mechanisms are the specific problem =
that I
am trying to address. Fortunately, these mechanisms seem to be rare: th=
e only
two that I know of are non-AF_UNIX sockets and ptrace(). All the other =
IPC
mechanisms that I have seen may be adequately restricted by changing fi=
le
permissions and ownership.

> If I had to sandbox something, I'd drop the process file limit to 0.=20

That is a technique that is commonly used by many people in this space.=
 It
works well for some limited use cases and, like SECCOMP, is too restric=
tive for
the kinds of general-purpose applications that I'm sandboxing.

If you're interested,

   http://cr.yp.to/unix/disablenetwork.html

lists several specific problems. To see more, just try dropping RLIMIT_=
NOFILE
to 0 before launching all your favorite apps. I'd be curious to hear ho=
w far
you get.

Regards,

Michael
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
