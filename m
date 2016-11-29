From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [net-next 1/1] samples: bpf: Refactor test_cgrp2_attach -- use
 getopt, and add mode
Date: Mon, 28 Nov 2016 21:50:16 -0800
Message-ID: <20161129055014.GA17751@ast-mbp.thefacebook.com>
References: <20161128225240.GA8761@ircssh.c.rugged-nimbus-611.internal>
 <20161129035020.GA15161@ast-mbp.thefacebook.com>
 <CAMp4zn8tGFxEBSMicv51hSofE_bRT9xd6rgtLFnVSLmhZ_sF_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <ast@fb.com>
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34961 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755490AbcK2FuV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 00:50:21 -0500
Received: by mail-pf0-f196.google.com with SMTP id i88so7624002pfk.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 21:50:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAMp4zn8tGFxEBSMicv51hSofE_bRT9xd6rgtLFnVSLmhZ_sF_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 09:42:25PM -0800, Sargun Dhillon wrote:
> On Mon, Nov 28, 2016 at 7:50 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Mon, Nov 28, 2016 at 02:52:42PM -0800, Sargun Dhillon wrote:
> >> This patch modifies test_cgrp2_attach to use getopt so we can use standard
> >> command line parsing.
> >>
> >> It also adds an option to run the program in detach only mode. This does
> >> not attach a new filter at the cgroup, but only runs the detach command.
> >>
> >> Lastly, it changes the attach code to not detach and then attach. It relies
> >> on the 'hotswap' behaviour of CGroup BPF programs to be able to change
> >> in-place. If detach-then-attach behaviour needs to be tested, the example
> >> can be run in detach only mode prior to attachment.
> >>
> >> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> >
> > looks fine to me.
> > I'd really prefer this example to become an automated test eventually.
> I can do that. As far as test cases:
> 
> 1. create /foo
> 2. enter foo
> 3. attach drop filter to foo
> 4. try to ping 127.0.0.1 (make sure it returns 0 replies)
> 5. create /foo/bar
> 6. enter /foo/bar
> 7. try to ping 127.0.0.1 (make sure it returns 0 replies)
> 8. attach passthrough filter to foo/bar
> 9. try to ping 127.0.0.1 (make sure it returns 1 replies)
> 10. Detach filter from foo/bar
> 11. try to ping 127.0.0.1 (make sure it returns 0 replies)
> Reasonable?

awesome. sounds like a plan.
