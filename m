From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 2/2] bpf: fix overflow in prog accounting
Date: Sat, 17 Dec 2016 11:03:43 +0100
Message-ID: <58550D7F.4060102@iogearbox.net>
References: <201612171034.Pd1bvSuT%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net, ast@fb.com,
        netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60239 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753801AbcLQKDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 05:03:55 -0500
In-Reply-To: <201612171034.Pd1bvSuT%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2016 03:52 AM, kbuild test robot wrote:
> Hi Daniel,
>
> [auto build test ERROR on net/master]
>
> url:    https://github.com/0day-ci/linux/commits/Daniel-Borkmann/bpf-dynamically-allocate-digest-scratch-buffer/20161217-090046
> config: sparc-defconfig (attached as .config)
> compiler: sparc-linux-gcc (GCC) 6.2.0
> reproduce:
>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>          chmod +x ~/bin/make.cross
>          # save the attached .config to linux build tree
>          make.cross ARCH=sparc
>
> All errors (new ones prefixed by >>):
>
>     kernel/bpf/core.c: In function '__bpf_prog_charge':
>>> kernel/bpf/core.c:80:50: error: 'struct user_struct' has no member named 'locked_vm'; did you mean 'locked_shm'?
>        user_bufs = atomic_long_add_return(pages, &user->locked_vm);
>                                                       ^~
>     kernel/bpf/core.c:82:32: error: 'struct user_struct' has no member named 'locked_vm'; did you mean 'locked_shm'?
>         atomic_long_sub(pages, &user->locked_vm);
>                                     ^~
>     kernel/bpf/core.c: In function '__bpf_prog_uncharge':
>     kernel/bpf/core.c:93:31: error: 'struct user_struct' has no member named 'locked_vm'; did you mean 'locked_shm'?
>        atomic_long_sub(pages, &user->locked_vm);

Argh, right, I'll send v2 later today.
