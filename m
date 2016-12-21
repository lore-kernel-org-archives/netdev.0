From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH perf/core REBASE 3/5] tools lib bpf: Add
 bpf_prog_{attach,detach}
Date: Wed, 21 Dec 2016 13:06:47 -0300
Message-ID: <20161221160647.GA3717@kernel.org>
References: <20161214224342.12858-1-joe@ovn.org>
 <20161214224342.12858-4-joe@ovn.org>
 <20161220141851.GB32756@kernel.org>
 <20161220143217.GC32756@kernel.org>
 <CAPWQB7HyzaAck1LEX_ec7gRpoKjyaZPZ+dco3Ca=sR4qQ403BQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Wang Nan <wangnan0@huawei.com>,
        ast@fb.com, Daniel Borkmann <daniel@iogearbox.net>
To: Joe Stringer <joe@ovn.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPWQB7HyzaAck1LEX_ec7gRpoKjyaZPZ+dco3Ca=sR4qQ403BQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Dec 20, 2016 at 10:50:22AM -0800, Joe Stringer escreveu:
> On 20 December 2016 at 06:32, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> > Em Tue, Dec 20, 2016 at 11:18:51AM -0300, Arnaldo Carvalho de Melo escreveu:
> >> This one makes it fail for CentOS 5 and 6, others may fail as well,
> >> still building, investigating...
> >
> > Ok, fixed it by making it follow the model of the other sys_bpf wrappers
> > setting up that bpf_attr union wrt initializing unamed struct members:
> > -       union bpf_attr attr = {
> > -               .target_fd = target_fd,
> > -       };
> > +       union bpf_attr attr;
> > +
> > +       bzero(&attr, sizeof(attr));
> > +       attr.target_fd     = target_fd;

> Ah, I just shifted these across originally so the delta would be
> minimal but now I know why this code is like this. Thanks.

np, making sure this code works in all those environments requires
automation, I'd say its impossible otherwise, too many details :-\

Fixed, pushed, merged, should hit 4.10 soon :-)

- Arnaldo
