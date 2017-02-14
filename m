From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 14 Feb 2017 14:23:26 +0100
Message-ID: <20170214132326.GD18546@krava>
References: <20170214091250.57d054b2@canb.auug.org.au>
 <20170214064221.GB10242@gmail.com>
 <20170214091937.GA18546@krava>
 <20170214125020.GA4458@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>,
        Alexander Shishkin <alexander.shishkin@linux.intel.com>,
        Arnaldo Carvalho de Melo <acme@infradead.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214125020.GA4458@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2017 at 09:50:20AM -0300, Arnaldo Carvalho de Melo wrote:

SNIP

> 
> What I think Ingo meant with dependency at the build system level is to
> somehow state that if file A gets changed, then tool B must be rebuilt.
> 
> Now that samples/bpf and tools/perf/ depend on tools/lib/bpf/ I _always_
> build both, ditto for tools/objtool, that shares a different library
> with tools/perf/, tools/lib/subcmd/:
> 
> ENTRYPOINT make -C /git/linux/tools/perf O=/tmp/build/perf && \
>            rm -rf /tmp/build/perf/{.[^.]*,*} && \
>            make NO_LIBELF=1 -C /git/linux/tools/perf O=/tmp/build/perf && \
>            make -C /git/linux/tools/objtool O=/tmp/build/objtool && \
>            make -C /git/linux O=/tmp/build/linux allmodconfig && \
>            make -C /git/linux O=/tmp/build/linux headers_install && \
>            make -C /git/linux O=/tmp/build/linux samples/bpf/
> 
> This is the default action for my
> docker.io/acmel/linux-perf-tools-build-fedora:rawhide container.
> 
> It is published, so a:
> 
>    docker pull docker.io/acmel/linux-perf-tools-build-fedora:rawhide
> 
> And then run it before pushing things upstream would catch these kinds
> of errors.
> 
> But that would possibly disrupt too much people's workflow, that is why
> using the Kbuild originated tools/build/ we have to somehow express that
> when a change is made in a file then a tool that uses that file needs to
> be rebuilt.

we already have the check in the check-headers.sh script,
an AFAICS there's no 'rebuild' option here.. just warn or fail
because the headers update needs to be done manualy

> 
> Makefile rules probably would be enough, but then it would have to be
> done at the tools/build/ level and all tools using shared components
> would have to use it to trigger the rebuild.

we can move/invoke the check-headers.sh script in some upper dir

jirka
