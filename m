From: C Anthony Risinger <anthony@xtfx.me>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Fri, 27 May 2011 15:18:45 -0500
Message-ID: <BANLkTimXMaYe9OYNhqPCiNnG2CqaQOt-yw@mail.gmail.com>
References: <m1wrhh3z62.fsf@fess.ebiederm.org> <BANLkTikW4vJbC8kcLSKuemUBbu36SO6hwg@mail.gmail.com>
 <20110525213806.GA4590@mail.hallyn.com> <BANLkTinbw6pZjhMscfXFMArd=XU=VC=+eQ@mail.gmail.com>
 <m17h9e1h9e.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m17h9e1h9e.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 6:40 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> C Anthony Risinger <anthony@xtfx.me> writes:
>
>> On Wed, May 25, 2011 at 4:38 PM, Serge E. Hallyn <serge@hallyn.com> =
wrote:
>>> Quoting C Anthony Risinger (anthony@xtfx.me):
>>>> On Mon, May 23, 2011 at 4:05 PM, Eric W. Biederman
>>>> <ebiederm@xmission.com> wrote:
>>>> >
>>>> > This tree adds the files /proc/<pid>/ns/net, /proc/<pid>/ns/ipc,
>>>> > /proc/<pid>/ns/uts that can be opened to refer to the namespaces=
 of a
>>>> > process at the time those files are opened, and can be bind moun=
ted to
>>>> > keep the specified namespace alive without a process.
>>>> >
>>>> > This tree adds the setns system call that can be used to change =
the
>>>> > specified namespace of a process to the namespace specified by a=
 system
>>>> > call.
>>>>
>>>> i just have a quick question regarding these, apologies if wrong p=
lace
>>>> to respond -- i trimmed to lists only.
>>>>
>>>> if i understand correctly, mount namespaces (for example), allow o=
ne
>>>> to build such constructs as "private /tmp" and similar that even
>>>> `root` cannot access ... and there are many reasons `root` does no=
t
>>>> deserve to completely know/interact with user processes (FUSE make=
s a
>>>> good example ... just because i [user] have SSH access to a machin=
e,
>>>> why should `root`?)
>>>>
>>>> would these /proc additions break such guarantees? =C2=A0IOW, woul=
d it now
>>>> become possible for `root` to inject stuff into my private namespa=
ces,
>>>> and/or has these guarantees never existed and i am mistaken? =C2=A0=
is there
>>>> any kind of ACL mechanism that endows the origin process (or simil=
ar)
>>>> with the ability to dictate who can hold and/or interact with thes=
e
>>>> references?
>>>
>>> If for instance you have a file open in your private /tmp, then roo=
t
>>> in another mounts ns can open the file through /proc/$$/fd/N anyway=
=2E
>>> If it's a directory, he can now traverse the whole fs.
>>
>> aaah right :-( ... there's always another way isn't there ... curse
>> you Linux for being so flexible! (just kidding baby i love you)
>
> Even more significant the access to the new files is guarded by the
> ptrace access checks. =C2=A0And if root can ptrace your process root
> can remote control your process.
>
>> this seems like a more fundamental issue then? =C2=A0or should i not=
 expect
>> to be able to achieve separation like this? =C2=A0i ask in the conte=
xt of
>> OS virt via cgroups + namespaces, eg. LXC et al, because i'm about t=
o
>> perform a massive overhaul to our crusty sub-2.6.18 infrastructure a=
nd
>> i've used/followed these technologies for couple years now ... and
>> it's starting to feel like "the right time".
>
> I don't think anything really new is allowed, but we haven't designed
> anything that radically reduces the power of root either.
>
> At some point we may have the user namespace done and that should
> give you a root like user with vastly reduced powers, but we aren't
> there yet.

ok -- i knew there was some user namespace work still left for a
namespaced root -- i was specifically thinking of the root user in the
host.  i was under the impression that namespaces could achieve
separation even from the host (save the kernel itself) ... but it
seems i was mistaken ... still much to learn about Linux i suppose,
even though i use it everyday for years and years :-)  it kind of
makes sense i guess, since maybe the host needs supervisory powers
over the guests?  could be some merit for real separation in the
future (not only malevolent root host user, but say an attacker/script
that manages to break thru container?), though how possible i dont
know.  i wouldnt expect the root user to be prevented from killing/etc
the container, but maybe only prevented from snooping, eg. the
container looks like a black box that he may only resource control or
kill completely.  either way, what we have is just fine for my (and
likely many other's) uses.

anyways, thanks for all the answers and all the work on
namespacing/cgroups ... very useful constructs for a wide array of
problems.

--=20

C Anthony
