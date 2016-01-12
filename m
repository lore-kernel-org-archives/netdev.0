From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net-next 2/4] bpf: bpf_htab: Add BPF_MAP_TYPE_PERCPU_HASH
Date: Mon, 11 Jan 2016 23:44:31 -0800
Message-ID: <20160112074420.GA55122@kafai-mba.local>
References: <1452206155-1492617-1-git-send-email-kafai@fb.com>
 <1452206155-1492617-3-git-send-email-kafai@fb.com>
 <CACVXFVNg_3j0T8WCmtVR8XEb9xRd0qJBEZcsW3_OJ+HYZHNvEg@mail.gmail.com>
 <20160112031148.GA13416@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	FB Kernel Team <kernel-team@fb.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160112031148.GA13416@kafai-mba.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 11, 2016 at 07:11:48PM -0800, Martin KaFai Lau wrote:
> On Sat, Jan 09, 2016 at 06:06:15PM +0800, Ming Lei wrote:
> > On Fri, Jan 8, 2016 at 6:35 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> > > This patch adds BPFMAP_TYPE_PERCPU_HASH map type and its
> > > htab_map_ops implementation.
> > >
> > > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > > ---
> > >  include/uapi/linux/bpf.h |   1 +
> > >  kernel/bpf/hashtab.c     | 201 ++++++++++++++++++++++++++++++++++++++++++++++-
> > >  2 files changed, 201 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> > > index 8bed7f1..e4f8060 100644
> > > --- a/include/uapi/linux/bpf.h
> > > +++ b/include/uapi/linux/bpf.h
> > > @@ -81,6 +81,7 @@ enum bpf_map_type {
> > >         BPF_MAP_TYPE_ARRAY,
> > >         BPF_MAP_TYPE_PROG_ARRAY,
> > >         BPF_MAP_TYPE_PERF_EVENT_ARRAY,
> > > +       BPF_MAP_TYPE_PERCPU_HASH,
> > >  };
> > >
> > >  enum bpf_prog_type {
> > > diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
> > > index d55df8c..63f2945 100644
> > > --- a/kernel/bpf/hashtab.c
> > > +++ b/kernel/bpf/hashtab.c
> > > @@ -278,7 +278,7 @@ find_first_elem:
> > >  }
> > >
> > >  static struct htab_elem_common *htab_elem_common_alloc(struct bpf_htab *htab,
> > > -                                                       void *key)
> > > +                                                      void *key)
> >
> > better to not introduce the above change.
> What is the concern?
Sorry. I misread your comment. will fix this unnecessary indentation change.
