From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [PATCH v4 1/2] bpf: Add bpf_probe_write BPF helper to be called
 in tracers (kprobes)
Date: Sat, 23 Jul 2016 17:39:42 -0700
Message-ID: <20160724003941.GA31582@ircssh.c.rugged-nimbus-611.internal>
References: <20160722010915.GA22992@ircssh.c.rugged-nimbus-611.internal>
 <20160722021454.GA135@ast-mbp.thefacebook.com>
 <5791ED30.3000409@iogearbox.net>
 <20160723000526.GA11650@ircssh.c.rugged-nimbus-611.internal>
 <20160723193510.GA23128@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160723193510.GA23128@ast-mbp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 23, 2016 at 12:35:12PM -0700, Alexei Starovoitov wrote:
> On Fri, Jul 22, 2016 at 05:05:27PM -0700, Sargun Dhillon wrote:
> > It was tested with the tracex7 program on x86-64.
> 
> it's my fault to start tracexN tradition that turned out to be
> cumbersome, let's not continue it. Instead could you rename it
> to something meaningful? Like test_probe_write_user ?
> Right now it just prints client's peer address and human needs to
> visually verify that probe_write_user actually happened, if you can
> convert it into a test it will help a lot.
> We were planning to convert all of the samples/bpf/ into tests,
> so we can run them continuously.
The example has been modified to act like a test in the follow up set. It tests 
for the positive case (Did the helper work or not) as opposed to the negative 
case (is the helper able to violate the safety constraints we set forth)? I 
could do that as well, in another patch by mprotecting those pages, or some 
such. Should I add an additional negative test?

> 
> btw, single patch re-submit will not be picked up. Please always
> re-submit the whole patch set together.
> 
I'll resubmit the set on another thread. It's just easier doing the reviews 
inline.


> > +static const struct bpf_func_proto *bpf_get_probe_write_proto(void) {
> > +	pr_warn_once("*****************************************************\n");
> > +	pr_warn_once("* bpf_probe_write_user: Experimental Feature in use *\n");
> > +	pr_warn_once("* bpf_probe_write_user: Feature may corrupt memory  *\n");
> > +	pr_warn_once("*****************************************************\n");
> > +	pr_notice_ratelimited("bpf_probe_write_user: %s[%d] installing program with helper: it may corrupt user memory!",
> > +	current->comm, task_pid_nr(current));
> 
> I thought we were argeeing on single pr_warn_ratelimited without banner ?
I'll switch to that.

> 
> The rest looks good.
> Thanks!
> 
