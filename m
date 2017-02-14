From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 14 Feb 2017 10:19:37 +0100
Message-ID: <20170214091937.GA18546@krava>
References: <20170214091250.57d054b2@canb.auug.org.au>
 <20170214064221.GB10242@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Arnaldo Carvalho de Melo <acme@kernel.org>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214064221.GB10242@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2017 at 07:42:21AM +0100, Ingo Molnar wrote:
> 
> * Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> 
> > Hi all,
> > 
> > After merging the net tree, today's linux-next build (powerpc64le perf)
> > failed like this:
> > 
> > Warning: tools/include/uapi/linux/bpf.h differs from kernel
> > bpf.c: In function 'bpf_prog_attach':
> > bpf.c:180:6: error: 'union bpf_attr' has no member named 'attach_flags'; did you mean 'map_flags'?
> >   attr.attach_flags  = flags;
> >       ^
> > 
> > Caused by commit
> > 
> >   7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE flag")
> > 
> > Unfortunately, the perf header files are kept separate from the kernel
> > header files proper and are not automatically copied over :-(
> 
> No, that's wrong, the problem is not that headers were not shared, the problem is 
> that a tooling interdependency was not properly tested *and* that the dependency 
> was not properly implemented in the build system either.
> 
> Note that we had similar build breakages when include headers _were_ shared as 
> well, so sharing the headers would only have worked around this particular bug and 
> would have introduced fragility in other places...
> 
> The best, most robust solution in this particular case would be to fix the 
> (tooling) build system to express the dependency, that would have shown the build 
> failure right when the modification was done.

so we have the warning now:
  Warning: tools/include/uapi/linux/bpf.h differs from kernel

do you want to change it into the build failure?

jirka
