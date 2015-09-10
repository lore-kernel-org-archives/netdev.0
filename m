From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Wed, 9 Sep 2015 18:13:15 -0600
Message-ID: <20150910001315.GF26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com>
 <20150904204554.GO26679@smitten>
 <CALCETrW5fS5d73ASJvhUuK=Yret7hcWD-B9NhZ3EsnCaw0MWFQ@mail.gmail.com>
 <20150904222855.GT26679@smitten>
 <CALCETrUY7B381DrzfDSvmDyZ98KAdWMHvpbJffJ0_ApjzH-Kbw@mail.gmail.com>
 <20150905002727.GA3890@hopstrocity>
 <20150909223422.GE26679@smitten>
 <CALCETrUhb9DiaJXppbJ4PwV1xD1cmd8xH+J27h6HQN23oRcO+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Cyrill Gorcunov <gorcunov@parallels.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:32872 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbbIJANR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 20:13:17 -0400
Received: by igbkq10 with SMTP id kq10so7631509igb.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 17:13:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALCETrUhb9DiaJXppbJ4PwV1xD1cmd8xH+J27h6HQN23oRcO+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 09, 2015 at 04:44:24PM -0700, Andy Lutomirski wrote:
> On Wed, Sep 9, 2015 at 3:34 PM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> >
> > Here's a thought,
> >
> > The set I'm currently proposing effectively separates the ref-counting
> > of the struct seccomp_filter from the struct bpf_prog (by necessity,
> > since we're referring to filters from fds). What if we went a little
> > futher, and made a copy of each seccomp_filter on fork(), keeping it
> > pointed at the same bpf_prog but adding some metadata about how it was
> > inherited (tsk->seccomp.filter->inheritence_count++ perhaps). This
> > would still require this change:
> 
> Won't that break the tsync mechanism?

We'll need the change I posted (is_ancestor comparing the underlying
bpf_prog instead of the seccomp_filter), but then I think it'll work.
I guess we'll need to do some more bookkeeping when we install filters
via TSYNC since each thread would need its own seccomp_filter, and
we'd also have to decide whether a filter installed via TSYNC was
inherited or not.

Am I missing something?

Tycho
