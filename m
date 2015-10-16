From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 19:21:45 +0200
Message-ID: <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
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
> 

Another question:
Should multiple mount of the filesystem result in an empty fs (a new
instance) or in one were one can see other ebpf-fs entities? I think
Daniel wanted to already use the mountpoint as some kind of hierarchy
delimiter. I would have used directories for that and multiple mounts
would then have resulted in the same content of the filesystem. IMHO
this would remove some ambiguity but then the question arises how this
is handled in a namespaced environment. Was there some specific reason
to do so?

Thanks,
Hannes
