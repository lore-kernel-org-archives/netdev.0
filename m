From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v3] bpf: Set register type according to is_valid_access()
Date: Mon, 26 Sep 2016 16:49:17 +0200
Message-ID: <57E9356D.70308@iogearbox.net>
References: <20160924180150.23620-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Kees Cook <keescook@chromium.org>,
        Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160924180150.23620-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/24/2016 08:01 PM, Mickaël Salaün wrote:
> This prevent future potential pointer leaks when an unprivileged eBPF
> program will read a pointer value from its context. Even if
> is_valid_access() returns a pointer type, the eBPF verifier replace it
> with UNKNOWN_VALUE. The register value that contains a kernel address is
> then allowed to leak. Moreover, this fix allows unprivileged eBPF
> programs to use functions with (legitimate) pointer arguments.
>
> Not an issue currently since reg_type is only set for PTR_TO_PACKET or
> PTR_TO_PACKET_END in XDP and TC programs that can only be loaded as
> privileged. For now, the only unprivileged eBPF program allowed is for
> socket filtering and all the types from its context are UNKNOWN_VALUE.
> However, this fix is important for future unprivileged eBPF programs
> which could use pointers in their context.
>
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>

Seems okay to me:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
