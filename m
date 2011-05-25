From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 16:40:13 -0700
Message-ID: <m17h9e1h9e.fsf@fess.ebiederm.org>
References: <m1wrhh3z62.fsf@fess.ebiederm.org>
	<BANLkTikW4vJbC8kcLSKuemUBbu36SO6hwg@mail.gmail.com>
	<20110525213806.GA4590@mail.hallyn.com>
	<BANLkTinbw6pZjhMscfXFMArd=XU=VC=+eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: C Anthony Risinger <anthony@xtfx.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTinbw6pZjhMscfXFMArd=XU=VC=+eQ@mail.gmail.com> (C. Anthony
	Risinger's message of "Wed, 25 May 2011 16:55:02 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

C Anthony Risinger <anthony@xtfx.me> writes:

> On Wed, May 25, 2011 at 4:38 PM, Serge E. Hallyn <serge@hallyn.com> w=
rote:
>> Quoting C Anthony Risinger (anthony@xtfx.me):
>>> On Mon, May 23, 2011 at 4:05 PM, Eric W. Biederman
>>> <ebiederm@xmission.com> wrote:
>>> >
>>> > This tree adds the files /proc/<pid>/ns/net, /proc/<pid>/ns/ipc,
>>> > /proc/<pid>/ns/uts that can be opened to refer to the namespaces =
of a
>>> > process at the time those files are opened, and can be bind mount=
ed to
>>> > keep the specified namespace alive without a process.
>>> >
>>> > This tree adds the setns system call that can be used to change t=
he
>>> > specified namespace of a process to the namespace specified by a =
system
>>> > call.
>>>
>>> i just have a quick question regarding these, apologies if wrong pl=
ace
>>> to respond -- i trimmed to lists only.
>>>
>>> if i understand correctly, mount namespaces (for example), allow on=
e
>>> to build such constructs as "private /tmp" and similar that even
>>> `root` cannot access ... and there are many reasons `root` does not
>>> deserve to completely know/interact with user processes (FUSE makes=
 a
>>> good example ... just because i [user] have SSH access to a machine=
,
>>> why should `root`?)
>>>
>>> would these /proc additions break such guarantees? =C2=A0IOW, would=
 it now
>>> become possible for `root` to inject stuff into my private namespac=
es,
>>> and/or has these guarantees never existed and i am mistaken? =C2=A0=
is there
>>> any kind of ACL mechanism that endows the origin process (or simila=
r)
>>> with the ability to dictate who can hold and/or interact with these
>>> references?
>>
>> If for instance you have a file open in your private /tmp, then root
>> in another mounts ns can open the file through /proc/$$/fd/N anyway.
>> If it's a directory, he can now traverse the whole fs.
>
> aaah right :-( ... there's always another way isn't there ... curse
> you Linux for being so flexible! (just kidding baby i love you)

Even more significant the access to the new files is guarded by the
ptrace access checks.  And if root can ptrace your process root
can remote control your process.

> this seems like a more fundamental issue then?  or should i not expec=
t
> to be able to achieve separation like this?  i ask in the context of
> OS virt via cgroups + namespaces, eg. LXC et al, because i'm about to
> perform a massive overhaul to our crusty sub-2.6.18 infrastructure an=
d
> i've used/followed these technologies for couple years now ... and
> it's starting to feel like "the right time".

I don't think anything really new is allowed, but we haven't designed
anything that radically reduces the power of root either.

At some point we may have the user namespace done and that should
give you a root like user with vastly reduced powers, but we aren't
there yet.

Eric
