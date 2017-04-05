From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH] ebpf: verify the output of the JIT
Date: Tue, 4 Apr 2017 21:45:36 -0600
Message-ID: <20170405034536.oulhc3ylhlrfgqeg@docker>
References: <20170404220810.14250-1-tycho@docker.com>
 <CAGXu5jLAXDk1+kYTC60-sJ_SOa5s4+HZ26A0bj67335yAXYhvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGXu5jLAXDk1+kYTC60-sJ_SOa5s4+HZ26A0bj67335yAXYhvg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Kees,

On Tue, Apr 04, 2017 at 03:17:57PM -0700, Kees Cook wrote:
> On Tue, Apr 4, 2017 at 3:08 PM, Tycho Andersen <tycho@docker.com> wrote:
> > The goal of this patch is to protect the JIT against an attacker with a
> > write-in-memory primitive. The JIT allocates a buffer which will eventually
> > be marked +x, so we need to make sure that what was written to this buffer
> > is what was intended.
> >
> > We acheive this by building a hash of the instruction buffer as
> > instructions are emittted and then comparing that to a hash at the end of
> > the JIT compile after the buffer has been marked read-only.
> >
> > Signed-off-by: Tycho Andersen <tycho@docker.com>
> > CC: Daniel Borkmann <daniel@iogearbox.net>
> > CC: Alexei Starovoitov <ast@kernel.org>
> > CC: Kees Cook <keescook@chromium.org>
> > CC: Mickaël Salaün <mic@digikod.net>
> 
> Cool! This closes the race condition on producing the JIT vs going
> read-only. I wonder if it might be possible to make this a more
> generic interface to the BPF which would be allocate the hash, provide
> the update callback during emit, and then do the hash check itself at
> the end of bpf_jit_binary_lock_ro()?

Yes, probably so. I can look into that for the next version.

Tycho
