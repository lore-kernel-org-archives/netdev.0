From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 12:25:03 +0200
Message-ID: <1444991103.2861759.411876897.42C807BD@webmail.messagingengine.com>
References: <cover.1444956943.git.daniel@iogearbox.net>
 <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	tgraf@suug.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2015, at 03:09, Daniel Borkmann wrote:
> This eventually leads us to this patch, which implements a minimal
> eBPF file system. The idea is a bit similar, but to the point that
> these inodes reside at one or multiple mount points. A directory
> hierarchy can be tailored to a specific application use-case from the
> various subsystem users and maps/progs pinned inside it. Two new eBPF
> commands (BPF_PIN_FD, BPF_NEW_FD) have been added to the syscall in
> order to create one or multiple special inodes from an existing file
> descriptor that points to a map/program (we call it eBPF fd pinning),
> or to create a new file descriptor from an existing special inode.
> BPF_PIN_FD requires CAP_SYS_ADMIN capabilities, whereas BPF_NEW_FD
> can also be done unpriviledged when having appropriate permissions
> to the path.

In my opinion this is very un-unixiy, I have to say at least.

Namespaces at some point dealt with the same problem, they nowadays use
bind mounts of /proc/$$/ns/* to some place in the file hierarchy to keep
the namespace alive. This at least allows someone to build up its own
hierarchy with normal unix tools and not hidden inside a C-program. For
filedescriptors we already have /proc/$$/fd/* but it seems that doesn't
work out of the box nowadays.

I don't know in terms of how many objects bpf should be able to handle
and if such a bind-mount based solution would work, I guess not.

In my opinion I still favor a user space approach. Subsystems which use
ebpf in a way that no user space program needs to be running to control
them would need to export the fds by itself. E.g. something like
sysfs/kobject for tc? The hierarchy would then be in control of the
subsystem which could also create a proper naming hierarchy or maybe
even use an already given one. Do most other eBPF users really need to
persist file descriptors somewhere without user space control and pick
them up later? 

Sorry for the rant and thanks for posting this patchset,
Hannes
