From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Identifying network namespaces (was: Network namespace
 manipulation with file descriptors)
Date: Wed, 18 May 2011 17:13:05 +0300
Message-ID: <BANLkTinx1i3UJ86xw8KdvF+dQ1-qNZfFtA@mail.gmail.com>
References: <m1tyd7p7tq.fsf@fess.ebiederm.org>
	<20110518124307.GD3762520@jupiter.n2.diac24.net>
	<BANLkTikmrC86hk=W84UBwhJLe_uGAN4w9w@mail.gmail.com>
	<20110518133352.GE3762520@jupiter.n2.diac24.net>
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
In-Reply-To: <20110518133352.GE3762520@jupiter.n2.diac24.net>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2011 at 4:33 PM, David Lamparter <equinox@diac24.net> w=
rote:
> On Wed, May 18, 2011 at 04:03:03PM +0300, Alexey Dobriyan wrote:
>> On Wed, May 18, 2011 at 3:43 PM, David Lamparter <equinox@diac24.net=
> wrote:
>> > - =A0 processes cannot easily be cross referenced with each other
>> >
>> > =A0in the case of user space stuff running astray - like managemen=
t
>> > =A0software crashing, routing daemons screwing up, etc. - it becom=
es
>> > =A0fairly difficult to shut down a network namespace (or even reaq=
uire
>> > =A0physical devices that have been reassigned)
>>
>> It shutdowns itself when last process using netns disappeares,
>> so if you kill your routing daemons you should be fine.
>> Physical netdevices are moved to init_net.
>
> Now assume I'm running pptpd, which forks a new pppd for each
> connection. Even if I kill pptpd, the pppd keeps running... now how d=
o I
> find the pppds that belong to that one namespace that I'm trying to
> get rid of?

That's a valid question.

>> > So, considering this set of premises (feedback welcome) I looked f=
or
>> > some suitable means of identification. I discarded going for any p=
rocess
>> > identifiers since Eric's patches allow for network namespaces with=
out
>> > any process holding a reference, using bind mounts instead.
>>
>> If anything it should be netns->id, /proc/*/netns outputting id
>> where id is not derived from kernel pointer.

Actually it should be symlink
/proc/net/netns -> 0         # for init_net
/proc/net/netns -> u32 (> 0)   # for the rest
to extract information by 1 syscall, not 3
where netns id is totally random, so userspace won't make assumptions.
