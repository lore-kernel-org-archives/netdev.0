From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v4 1/2] bpf: Add bpf_probe_write BPF helper to be called
 in tracers (kprobes)
Date: Sat, 23 Jul 2016 12:35:12 -0700
Message-ID: <20160723193510.GA23128@ast-mbp>
References: <20160722010915.GA22992@ircssh.c.rugged-nimbus-611.internal>
 <20160722021454.GA135@ast-mbp.thefacebook.com>
 <5791ED30.3000409@iogearbox.net>
 <20160723000526.GA11650@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35150 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbcGWThh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2016 15:37:37 -0400
Content-Disposition: inline
In-Reply-To: <20160723000526.GA11650@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 22, 2016 at 05:05:27PM -0700, Sargun Dhillon wrote:
> It was tested with the tracex7 program on x86-64.

it's my fault to start tracexN tradition that turned out to be
cumbersome, let's not continue it. Instead could you rename it
to something meaningful? Like test_probe_write_user ?
Right now it just prints client's peer address and human needs to
visually verify that probe_write_user actually happened, if you can
convert it into a test it will help a lot.
We were planning to convert all of the samples/bpf/ into tests,
so we can run them continuously.

btw, single patch re-submit will not be picked up. Please always
re-submit the whole patch set together.

> +static const struct bpf_func_proto *bpf_get_probe_write_proto(void) {
> +	pr_warn_once("*****************************************************\n");
> +	pr_warn_once("* bpf_probe_write_user: Experimental Feature in use *\n");
> +	pr_warn_once("* bpf_probe_write_user: Feature may corrupt memory  *\n");
> +	pr_warn_once("*****************************************************\n");
> +	pr_notice_ratelimited("bpf_probe_write_user: %s[%d] installing program with helper: it may corrupt user memory!",
> +	current->comm, task_pid_nr(current));

I thought we were argeeing on single pr_warn_ratelimited without banner ?

The rest looks good.
Thanks!
