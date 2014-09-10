From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2] net: bpf: only build bpf_jit_binary_{alloc,free}()
 when jit selected
Date: Wed, 10 Sep 2014 10:48:54 -0700
Message-ID: <CAHA+R7O_352QUc+FDgf4w2r3SuMcjMhCZhPPYQdk32Lez1efeQ@mail.gmail.com>
References: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:42000 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715AbaIJRs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 13:48:56 -0400
Received: by mail-la0-f54.google.com with SMTP id ge10so817495lab.41
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 10:48:55 -0700 (PDT)
In-Reply-To: <1410354062-25337-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 6:01 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Since BPF JIT depends on the availability of module_alloc() and
> module_free() helpers (HAVE_BPF_JIT and MODULES), we better build
> that code only in case we have BPF_JIT in our config enabled, just
> like with other JIT code. Fixes builds for arm/marzen_defconfig
> and sh/rsk7269_defconfig.

It is quite useful to include the build failure in changelog:

kernel/built-in.o: In function `bpf_jit_binary_alloc':
/home/cwang/linux/kernel/bpf/core.c:144: undefined reference to `module_alloc'
kernel/built-in.o: In function `bpf_jit_binary_free':
/home/cwang/linux/kernel/bpf/core.c:164: undefined reference to `module_free'
make: *** [vmlinux] Error 1
