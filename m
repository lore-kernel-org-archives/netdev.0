From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 net-next 4/6] perf, bpf: add perf events core support
 for BPF_PROG_TYPE_PERF_EVENT programs
Date: Thu, 1 Sep 2016 18:37:22 +0200
Message-ID: <20160901163722.GY10153@twins.programming.kicks-ass.net>
References: <1472680243-1326608-1-git-send-email-ast@fb.com>
 <1472680243-1326608-5-git-send-email-ast@fb.com>
 <20160901081251.GL10153@twins.programming.kicks-ass.net>
 <20160901155349.GA88787@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-team@fb.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52282 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752547AbcIAQhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:37:31 -0400
Content-Disposition: inline
In-Reply-To: <20160901155349.GA88787@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 08:53:51AM -0700, Alexei Starovoitov wrote:
> On Thu, Sep 01, 2016 at 10:12:51AM +0200, Peter Zijlstra wrote:

> > Please, no leading space before labels. Use something like:
> 
> good catch.
> sadly checkpatch didn't complain.

Right, a lot of people do it on purpose to avoid diff seeing the label
as the function for --show-c-function. I just find the style annoying
and 'fixed' diff.

Now, if the option would've been called --show-function (without the
explicit reference to C) one could argue that seeing this form is useful
for .S files but... ;-)

> > [diff "default"]
> >         xfuncname = "^[[:alpha:]$_].*[^:]$"
> > 
> > In your .gitconfig if you want to keep diff output 'sane'.
> 
> interesting trick. don't remember being bitten by it.
> This extra space was a typo.

Example below, see the difference in the @@ line. I find the first
(fixed) to be much more useful.

With:

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 8b3ad4e26548..cc2af0188924 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6238,6 +6238,7 @@ static void perf_pmu_output_stop(struct perf_event *event)
 			goto restart;
 		}
 	}
+	/* ponies */
 	rcu_read_unlock();
 }
 


Without:

diff --git a/kernel/events/core.c b/kernel/events/core.c
index 8b3ad4e26548..cc2af0188924 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6238,6 +6238,7 @@ restart:
 			goto restart;
 		}
 	}
+	/* ponies */
 	rcu_read_unlock();
 }
 
