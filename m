From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [RFC: add openvswitch actions using BPF 4/9] autoconf: support
 -with-llc options
Date: Fri, 6 Feb 2015 10:12:49 -0800
Message-ID: <CANr6G5x9KK-Cm1tnXW0uX-bw+4+p-sxe4=t7aSZwvs8iUGQfQQ@mail.gmail.com>
References: <1423090163-19902-1-git-send-email-azhou@nicira.com> <1423090163-19902-5-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.com" <dev@openvswitch.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:60214 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758105AbbBFSNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 13:13:10 -0500
Received: by mail-we0-f173.google.com with SMTP id w55so3705073wes.4
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 10:13:09 -0800 (PST)
In-Reply-To: <1423090163-19902-5-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4 February 2015 at 14:49, Andy Zhou <azhou@nicira.com> wrote:
> Add a configuration option to allow specifing the LLVM backend module
> for compiling BPF C source code into BPF instruction sets.
>
> See INSTALL.BPF.md for usgae information.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> ---
>  INSTALL.BPF.md | 42 ++++++++++++++++++++++++++++++++++++++++++
>  Makefile.am    |  1 +
>  acinclude.m4   | 16 ++++++++++++++++
>  configure.ac   |  2 ++
>  4 files changed, 61 insertions(+)
>  create mode 100644 INSTALL.BPF.md
>
> diff --git a/INSTALL.BPF.md b/INSTALL.BPF.md
> new file mode 100644
> index 0000000..bc1f5ad
> --- /dev/null
> +++ b/INSTALL.BPF.md
> @@ -0,0 +1,42 @@
> +# Dependencies
> +
> +- Need Clang + llvm-dev version 3.X for any (2 <= X <= 4)
> +- http://llvm.org/apt/
> +
> +apt-get install libelf-dev clang-3.4 llvm-3.4-dev
> +
> +# Build LLVM plugin
> +
> +*[Upstream] git://git.kernel.org/pub/scm/linux/kernel/git/ast/bpf*
> +
> +git clone git://github.com/joestringer/linux
> +NN=$PWD/linux
> +
> +cd $NN/tools/bpf/llvm/bld
> +make LLVM_CONFIG=`which llvm-config-3.4`
> +
> +# Configure OVS to use BPF LLC
> +
> +OVS=/path/to/openvswitch
> +cd $OVS
> +./configure --with-llc=$NN/tools/bpf/llvm/bld/Debug+Asserts/bin/llc

Naturally we'd need to update these instructions, this becomes much
simpler if we just require clang-3.7.
