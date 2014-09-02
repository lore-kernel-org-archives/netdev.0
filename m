From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: bpf: make eBPF interpreter images
 read-only
Date: Tue, 02 Sep 2014 14:40:59 -0700
Message-ID: <1409694059.26422.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <aa5126f747594d768e0c518189a13e8674ad8ee5.1409690486.git.hannes@stressinduktion.org>
	 <2bf2e54282097642db88e2b596b06a9ac3742883.1409690849.git.hannes@stressinduktion.org>
	 <CAMEtUuyoWELJ0Yf+=5sDKxFEfgsiQ3kMCK+Wn_bdJgS8qaH2og@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Brad Spengler <spender@grsecurity.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Kees Cook <keescook@chromium.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyoWELJ0Yf+=5sDKxFEfgsiQ3kMCK+Wn_bdJgS8qaH2og@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-02 at 14:31 -0700, Alexei Starovoitov wrote:

> > +static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
> > +{
> > +       set_memory_rw((unsigned long)fp, fp->pages);
> 
> why rw is needed?
> since fp is allocated with vmalloc, vfree doesn't need
> to touch the pages to free them, no?

That assumes that vmalloc() do not have any debugging features, like
poisoning content before freeing, to catch some use after free.

Lets be clean and safe, and give back same memory permission we had
after vmalloc()
