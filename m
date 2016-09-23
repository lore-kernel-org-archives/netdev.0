From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: Set register type according to is_valid_access()
Date: Thu, 22 Sep 2016 17:08:52 -0700
Message-ID: <20160923000851.GB36167@ast-mbp.thefacebook.com>
References: <20160922195647.27914-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Kees Cook <keescook@chromium.org>,
        Sargun Dhillon <sargun@sargun.me>, Tejun Heo <tj@kernel.org>,
        netdev@vger.kernel.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160922195647.27914-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2016 at 09:56:47PM +0200, Mickaël Salaün wrote:
> This fix a pointer leak when an unprivileged eBPF program read a pointer
> value from the context. Even if is_valid_access() returns a pointer
> type, the eBPF verifier replace it with UNKNOWN_VALUE. The register
> value containing an address is then allowed to leak. Moreover, this
> prevented unprivileged eBPF programs to use functions with (legitimate)
> pointer arguments.
> 
> This bug is not an issue for now because the only unprivileged eBPF
> program allowed is of type BPF_PROG_TYPE_SOCKET_FILTER and all the types
> from its context are UNKNOWN_VALUE. However, this fix is important for
> future unprivileged eBPF program types which could use pointers in their
> context.
> 
> Signed-off-by: Mickaël Salaün <mic@digikod.net>
> Fixes: 969bf05eb3ce ("bpf: direct packet access")

Please drop 'fixes' tag and rewrite commit log.
It's not a fix.
Right now only two reg types can be seen: PTR_TO_PACKET and PTR_TO_PACKET_END.
Both are only in clsact and xdp programs which are root only.
So nothing is leaking at present.
Best case this patch is a pre-patch for some future work.
