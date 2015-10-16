From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 14:53:10 -0500
Message-ID: <87y4f2io9l.fsf@x220.int.ebiederm.org>
References: <cover.1444956943.git.daniel@iogearbox.net>
	<ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
	<1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
	<5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
	<87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56214FAC.5060704@plumgrid.com> (Alexei Starovoitov's message of
	"Fri, 16 Oct 2015 12:27:40 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexei Starovoitov <ast@plumgrid.com> writes:

> On 10/16/15 11:41 AM, Eric W. Biederman wrote:
[...]
>> I am missing something.
>>
>> When I suggested using a filesystem it was my thought there would be
>> exactly one superblock per map, and the map would be specified at mount
>> time.  You clearly are not implementing that.
>
> I don't think it's practical to have sb per map, since that would mean
> sb per prog and that won't scale.

What do you mean won't scale?  You want to have a name per map/prog so the
basic complexity appears the same.  Is there some crucial interaction
between the persistent dodads you are placing on a filesystem that I am
missing?

Given the fact you don't normally need any persistence without a program
I am puzzled why "scaling" is an issue of any kind.  This is for a
comparitively rare case if I am not mistaken.

> Also map today is an fd that belongs to a process. I cannot see
> an api from C program to do 'mount of FD' that wouldn't look like
> ugly hack.

mount -t bpffs ... -o fd=1234 

That is not all convoluted or hacky.  Especially compared to some of the
alternatives I am seeing.

It is no problem at all to wrap something like that in a nice function
call that has the exact same complexity of use as any of the other
options that are being explored to give something that starts out
as a filedescriptor a name.

>> A filesystem per map makes sense as you have a key-value store with one
>> file per key.
>>
>> The idea is that something resembling your bpf_pin_fd function would be
>> the mount system call for the filesystem.
>>
>> The the keys in the map could be read by "ls /mountpoint/".
>> Key values could be inspected with "cat /mountpoint/key".
>
> yes. that is still the goal for follow up patches, but contained
> within given bpffs. Something bpf_pin_fd-like command for bpf syscall
> would create files for keys in a map and allow 'cat' via open/read.
> Such api would be much cleaner from C app point of view.
> Potentially we can allow mount of a file created via BPF_PIN_FD
> that will expand into keys/values.
> All of that are our future plans.
> There, actually, the main contention point is 'how to represent keys
> and values'. whether key is hex representation or we need some
> pretty-printers via format string or via schema? etc, etc.
> We tried few ideas of representing keys in our fuse implementations,
> but don't have an agreement yet.

My gut feel would be to keep it simple and use the same representation
you use in your existing system calls.  Certainly ordinary filenames are
keys of arbitrary binary data that can included everything except
a '\0' byte.  That they are human readable is a nice convention, but not
at all fundamental to what they are.

Eric
