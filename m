From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Relax kern_version constraints on bpf kprobes?
Date: Sat, 23 Jul 2016 21:36:33 -0700
Message-ID: <20160724043630.GA36109@ast-mbp.thefacebook.com>
References: <20160724040139.GA2025@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160724040139.GA2025@ircssh.c.rugged-nimbus-611.internal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 09:01:39PM -0700, Sargun Dhillon wrote:
> In kernel/bpf/syscall.c we restrict programs loading bpf kprobe programs so 
> attr.kern_version must be exactly equal to what the user is running at the 
> moment. This makes a lot of sense because kprobes can touch lots of
> unstable bits of the kernel ABI. 
> 
> Unfortunately, this makes it really difficult to ship binary bpf programs
> for debugging, and most customers don't want to go through all the steps
> of preparing for compilation and installation of bpf programs for their 
> specific kernel that was shipped by their vendor. 
> 
> This is especially problematic when the probe is touching only stable ABIs
> (syscalls), or alternatively is just logging performance events. I realize
> that we can change this section pretty easily by reading the version at
> load time and modifying it, but it's kind of a pain.
> 
> For programs that we know are safe, is there a mechanism by which we can
> bypass this check, and tell the loader that we know what we're doing
> since these programs are only accessible to CAP_SYS_ADMIN?

The proper alternative is to always compile programs on the fly
for the given kernel like iovisor/bcc does. Integrated clang/llvm
has other advantages, like being able to search/replace in bpf C program
before installing it in the kernel. So different command line flags
come with zero overhead when not in use.
