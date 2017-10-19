From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: linux-next: /home/broonie/tmpfs/next/kernel/bpf/verifier.c:
Date: Thu, 19 Oct 2017 16:04:33 +0200
Message-ID: <59E8B0F1.40509@iogearbox.net>
References: <20171019135523.w7ljx34hyx7422nb@sirena.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Mark Brown <broonie@kernel.org>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38007 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753973AbdJSOEl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 10:04:41 -0400
In-Reply-To: <20171019135523.w7ljx34hyx7422nb@sirena.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2017 03:55 PM, Mark Brown wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (x86allmodconfig)
> failed like this:
>
> /home/broonie/tmpfs/next/kernel/bpf/verifier.c: In function 'check_mem_access':
> /home/broonie/tmpfs/next/kernel/bpf/verifier.c:1010:12: error: passing argument 1 of 'verbose' from incompatible pointer type [-Werror=incompatible-pointer-types]
>      verbose("dereference of modified ctx ptr R%d off=%d+%d, ctx+const is allowed, ctx+const+const is not\n",
>              ^

Yeah, the verbose calls need to have env passed into them:

   verbose(env, [...])

See also the note below '---':

   http://patchwork.ozlabs.org/patch/826449/

> /home/broonie/tmpfs/next/kernel/bpf/verifier.c:173:28: note: expected 'struct bpf_verifier_env *' but argument is of type 'char *'
>   static __printf(2, 3) void verbose(struct bpf_verifier_env *env,
>                              ^
> /home/broonie/tmpfs/next/kernel/bpf/verifier.c:1011:5: warning: passing argument 2 of 'verbose' makes pointer from integer without a cast [-Wint-conversion]
>       regno, reg->off, off - reg->off);
>       ^
> /home/broonie/tmpfs/next/kernel/bpf/verifier.c:173:28: note: expected 'const char *' but argument is of type 'u32 {aka unsigned int}'
>   static __printf(2, 3) void verbose(struct bpf_verifier_env *env,
>                              ^
> cc1: some warnings being treated as errors
> /home/broonie/tmpfs/next/scripts/Makefile.build:313: recipe for target 'kernel/bpf/verifier.o' failed
>
> Caused by commit
>
>    28e33f9d78eef ("bpf: disallow arithmetic operations on context pointer")
>
> interacting with
>
>    61bd5218eef34 ("bpf: move global verifier log into verifier environment")
>
