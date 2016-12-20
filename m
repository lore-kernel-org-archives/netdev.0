From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: kernel/bpf/verifier.c: 4 * possible unintended fallthrough ?
Date: Tue, 20 Dec 2016 08:17:33 -0800
Message-ID: <CAADnVQ+_2D9ExoyiDbMFUNk0KSMQVYQSND+eca0O3r_fku1L2g@mail.gmail.com>
References: <VI1PR08MB102286884ADF02FB45C203109C900@VI1PR08MB1022.eurprd08.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "ast@kernel.org" <ast@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Binderman <dcb314@hotmail.com>, Josef Bacik <jbacik@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <VI1PR08MB102286884ADF02FB45C203109C900@VI1PR08MB1022.eurprd08.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 3:20 AM, David Binderman <dcb314@hotmail.com> wrote:
> Hello there,
>
> I just tried to compile kernel-4.9 with a recent development
> version of gcc. It said
>
> kernel/bpf/verifier.c:1907:23: warning: this statement may fall through [-Wimplicit-fallthrough=]
> kernel/bpf/verifier.c:1918:23: warning: this statement may fall through [-Wimplicit-fallthrough=]
> kernel/bpf/verifier.c:1859:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
> kernel/bpf/verifier.c:1869:24: warning: this statement may fall through [-Wimplicit-fallthrough=]
>
> Source code for the first one is
>
>     case BPF_JGT:
>         /* Unsigned comparison, the minimum value is 0. */
>         true_reg->min_value = 0;
>     case BPF_JSGT:
>
> Suggest either add the missing break or document the fallthrough
> with a comment something like /* FALLTHROUGH */

I've tried 4.9 and 5.2 and don't see this warning.
Is this 6.x gcc?
I suspect it will have such warnings all over the kernel.
