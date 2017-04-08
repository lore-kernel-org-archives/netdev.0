From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next] bpf: taint loading !is_gpl programs
Date: Sat, 8 Apr 2017 19:11:28 -0400
Message-ID: <20170408231124.GA6221@ast-mbp.thefacebook.com>
References: <20170404183354.8579-1-aconole@bytheb.org>
 <58E40C2B.7040802@iogearbox.net>
 <f7tpogqmeai.fsf@redhat.com>
 <20170406124059.GB53880@ast-mbp.thefacebook.com>
 <f7tk26w3ybv.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Aaron Conole <aconole@bytheb.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f7tk26w3ybv.fsf@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 07, 2017 at 01:46:28PM -0400, Aaron Conole wrote:
> Hi Alexei, and Daniel,
> 
> Alexei Starovoitov <alexei.starovoitov@gmail.com> writes:
> 
> > On Wed, Apr 05, 2017 at 10:59:49PM -0400, Aaron Conole wrote:
> >> Hi Daniel,
> >> 
> >> Daniel Borkmann <daniel@iogearbox.net> writes:
> >> 
> >> > On 04/04/2017 08:33 PM, Aaron Conole wrote:
> >> >> The eBPF framework is used for more than just socket level filtering.  It
> >> >> can also provide tracing, and even change the way packets coming into the
> >> >> system look.  Most of the eBPF callable symbols are available to non-gpl
> >> >> programs, and this includes helper functions which modify packets.  This
> >> >> allows proprietary eBPF code to link to the kernel and make decisions
> >> >> which can negatively impact network performance.
> >> >>
> >> >> Since the sources for these programs are only available under a proprietary
> >> >> license, it seems better to treat them the same as other proprietary
> >> >> modules: set the system taint flag.  An exemption is made for socket-level
> >> >> filters, since they do not really impact networking for the whole kernel.
> >> >>
> >> >> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> >> >> ---
> >> >
> >> > Nacked-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> Given we have different views about this, I think I am okay with some
> middle ground.
> 
> Here's the next-steps plan.  Please tell if you dislike it or want to
> change it:
> 
> 1. Add a ref counter for tracking load and unload, which can be queried
> from a procfs or bpf fs interface
> 
> 2. Add a new print during panic when the refcount is non-zero.
> 
> This lets us know that there could be some kind of ebpf program loaded,
> and we would ask for sources before trying to disassemble.
> 
> Does this sound reasonable?

yeah. for the purpose of identifying whether any classic or extended bpf
programs loaded that makes sense. The only question how far we should
take it, since nft and acpi bytecode falls into the same category.
Also my understanding this is just one of out of many items on
redhat todo list to make bpf supported in rhel, so I think it makes
sense to discuss the whole list all at once. If we add patches here and
there without having full picture we may end up with obsolete api
or api superseded by other patches/features.
So let's discuss all feature requests first.
