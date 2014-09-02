From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next v2] net: bpf: make eBPF interpreter images read-only
Date: Tue, 2 Sep 2014 14:31:47 -0700
Message-ID: <CAMEtUuyoWELJ0Yf+=5sDKxFEfgsiQ3kMCK+Wn_bdJgS8qaH2og@mail.gmail.com>
References: <aa5126f747594d768e0c518189a13e8674ad8ee5.1409690486.git.hannes@stressinduktion.org>
	<2bf2e54282097642db88e2b596b06a9ac3742883.1409690849.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brad Spengler <spender@grsecurity.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Kees Cook <keescook@chromium.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2bf2e54282097642db88e2b596b06a9ac3742883.1409690849.git.hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 2, 2014 at 1:53 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
>
> With eBPF getting more extended and exposure to user space is on it's way,
> hardening the memory range the interpreter uses to steer its command flow
> seems appropriate.  This patch moves the to be interpreted bytecode to
> read-only pages.
...
>  11 files changed, 144 insertions(+), 32 deletions(-)

nice. quite short.

> +#ifdef CONFIG_DEBUG_SET_MODULE_RONX
> +static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
> +{
> +       set_memory_ro((unsigned long)fp, fp->pages);

since ronx are ifdef checked together,
would probably make sense to set nx too?

> +static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
> +{
> +       set_memory_rw((unsigned long)fp, fp->pages);

why rw is needed?
since fp is allocated with vmalloc, vfree doesn't need
to touch the pages to free them, no?
