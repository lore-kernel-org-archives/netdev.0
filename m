From: C Anthony Risinger <anthony@xtfx.me>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 16:55:02 -0500
Message-ID: <BANLkTinbw6pZjhMscfXFMArd=XU=VC=+eQ@mail.gmail.com>
References: <m1wrhh3z62.fsf@fess.ebiederm.org> <BANLkTikW4vJbC8kcLSKuemUBbu36SO6hwg@mail.gmail.com>
 <20110525213806.GA4590@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110525213806.GA4590@mail.hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 4:38 PM, Serge E. Hallyn <serge@hallyn.com> wro=
te:
> Quoting C Anthony Risinger (anthony@xtfx.me):
>> On Mon, May 23, 2011 at 4:05 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>> >
>> > This tree adds the files /proc/<pid>/ns/net, /proc/<pid>/ns/ipc,
>> > /proc/<pid>/ns/uts that can be opened to refer to the namespaces o=
f a
>> > process at the time those files are opened, and can be bind mounte=
d to
>> > keep the specified namespace alive without a process.
>> >
>> > This tree adds the setns system call that can be used to change th=
e
>> > specified namespace of a process to the namespace specified by a s=
ystem
>> > call.
>>
>> i just have a quick question regarding these, apologies if wrong pla=
ce
>> to respond -- i trimmed to lists only.
>>
>> if i understand correctly, mount namespaces (for example), allow one
>> to build such constructs as "private /tmp" and similar that even
>> `root` cannot access ... and there are many reasons `root` does not
>> deserve to completely know/interact with user processes (FUSE makes =
a
>> good example ... just because i [user] have SSH access to a machine,
>> why should `root`?)
>>
>> would these /proc additions break such guarantees? =C2=A0IOW, would =
it now
>> become possible for `root` to inject stuff into my private namespace=
s,
>> and/or has these guarantees never existed and i am mistaken? =C2=A0i=
s there
>> any kind of ACL mechanism that endows the origin process (or similar=
)
>> with the ability to dictate who can hold and/or interact with these
>> references?
>
> If for instance you have a file open in your private /tmp, then root
> in another mounts ns can open the file through /proc/$$/fd/N anyway.
> If it's a directory, he can now traverse the whole fs.

aaah right :-( ... there's always another way isn't there ... curse
you Linux for being so flexible! (just kidding baby i love you)

this seems like a more fundamental issue then?  or should i not expect
to be able to achieve separation like this?  i ask in the context of
OS virt via cgroups + namespaces, eg. LXC et al, because i'm about to
perform a massive overhaul to our crusty sub-2.6.18 infrastructure and
i've used/followed these technologies for couple years now ... and
it's starting to feel like "the right time".

C Anthony
