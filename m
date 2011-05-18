From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Identifying network namespaces (was: Network namespace
 manipulation with file descriptors)
Date: Wed, 18 May 2011 16:03:03 +0300
Message-ID: <BANLkTikmrC86hk=W84UBwhJLe_uGAN4w9w@mail.gmail.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<20110518124307.GD3762520@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	jamal <hadi@cyberus.ca>, Daniel Lezcano <daniel.lezcano@free.fr>,
	Linux Containers <containers@lists.osdl.org>,
	Renato Westphal <renatowestphal@gmail.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20110518124307.GD3762520@jupiter.n2.diac24.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 3:43 PM, David Lamparter <equinox@diac24.net> w=
rote:
> - =A0 processes cannot easily be cross referenced with each other
>
> =A0in the case of user space stuff running astray - like management
> =A0software crashing, routing daemons screwing up, etc. - it becomes
> =A0fairly difficult to shut down a network namespace (or even reaquir=
e
> =A0physical devices that have been reassigned)

It shutdowns itself when last process using netns disappeares,
so if you kill your routing daemons you should be fine.
Physical netdevices are moved to init_net.

> - =A0 namespaces cannot adequately be identified to the user
>
> =A0for debugging, some kernel messages become useless. most prominent=
ly,
> =A0"unregister_netdevice: waiting for lo to become free. Usage count =
=3D 123"
> =A0could certainly use some clarification, *which* lo is meant...

There is no "netns %p" or something, because right now the only unique
netns identifier is kernel pointer (which better not be exposed to user=
space).
Printing such thing would be quite useless since it's not printed
at netns creation.

> So, considering this set of premises (feedback welcome) I looked for
> some suitable means of identification. I discarded going for any proc=
ess
> identifiers since Eric's patches allow for network namespaces without
> any process holding a reference, using bind mounts instead.

If anything it should be netns->id, /proc/*/netns outputting id
where id is not derived from kernel pointer.

> Solution?
> =3D=3D=3D=3D=3D=3D=3D=3D=3D

What a hack! :-)
