From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 13:41:55 -0500
Message-ID: <87d1welkp8.fsf@x220.int.ebiederm.org>
References: <cover.1444956943.git.daniel@iogearbox.net>
	<ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
	<1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
	<5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56213A61.40509@iogearbox.net> (Daniel Borkmann's message of
	"Fri, 16 Oct 2015 19:56:49 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Borkmann <daniel@iogearbox.net> writes:

> On 10/16/2015 07:42 PM, Alexei Starovoitov wrote:
>> On 10/16/15 10:21 AM, Hannes Frederic Sowa wrote:
>>> Another question:
>>> Should multiple mount of the filesystem result in an empty fs (a new
>>> instance) or in one were one can see other ebpf-fs entities? I think
>>> Daniel wanted to already use the mountpoint as some kind of hierarchy
>>> delimiter. I would have used directories for that and multiple mounts
>>> would then have resulted in the same content of the filesystem. IMHO
>>> this would remove some ambiguity but then the question arises how this
>>> is handled in a namespaced environment. Was there some specific reason
>>> to do so?
>>
>> That's an interesting question!
>> I think all mounts should be independent.
>> I can see tracing using one and networking using another one
>> with different hierarchies suitable for their own use cases.
>> What's an advantage to have the same content everywhere?
>> Feels harder to manage, since different users would need to
>> coordinate.
>
> I initially had it as a mount_single() file system, where I was thinking
> to have an entry under /sys/fs/bpf/, so all subsystems would work on top
> of that mount point, but for the same reasons above I lifted that restriction.

I am missing something.

When I suggested using a filesystem it was my thought there would be
exactly one superblock per map, and the map would be specified at mount
time.  You clearly are not implementing that.

A filesystem per map makes sense as you have a key-value store with one
file per key.

The idea is that something resembling your bpf_pin_fd function would be
the mount system call for the filesystem.

The the keys in the map could be read by "ls /mountpoint/".
Key values could be inspected with "cat /mountpoint/key".

That allows all hierarchy etc to be handled in userspace, just as with
my files for namespaces.

I do not understand why you have presented to userspace a magic
filesystem that you allow binding to.  That is not what I intended to
suggest and I do not know how that makes any sense.

Eric
