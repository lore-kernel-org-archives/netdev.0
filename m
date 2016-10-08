From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Code quality and XDP
Date: Sat, 8 Oct 2016 06:28:17 +0200
Message-ID: <20161008062817.45d6ac2b@redhat.com>
References: <CALx6S37LyR7NGkmxFrP67GVPsyke+BM9eZm0PSw+vQo3+wjSuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58208 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750730AbcJHE21 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Oct 2016 00:28:27 -0400
In-Reply-To: <CALx6S37LyR7NGkmxFrP67GVPsyke+BM9eZm0PSw+vQo3+wjSuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 8 Oct 2016 07:25:01 +0900 Tom Herbert <tom@herbertland.com> wrote:

> One concern raised at netdev concerning XDP is how are we going to
> maintain code quality, security, and correctness of programs being
> loaded. With kernel bypass it is not just the kernel code path that is
> being bypassed, but also the processes that hold the quality of code
> being accepted to a high bar. Our users expect that quality to be
> maintained.
> 
> I suggest that we need XDP programs to be subject to the same scrutiny
> that any other kernel netdev code is. One idea is to sign programs
> that have been accepted into the kernel. By default only signed
> programs would be allowed to be loaded, the override to allow unsigned
> programs might be a kernel config or a least a boot parameter
> (enabling the override needs to be very explicit).

Sorry, I think this "lock-down" will kill the DDoS use-case.  In the
DDoS mitigation use-case, is all about flexibility to adapt quickly to
changing attacks.  Thus, you need the ability to quickly modify your
programs to catch attack signatures.


> The acceptable XDP programs should probably be under their own
> directory. Such a directory should only contain kernel code, not
> userspace code also as is currently in samples/bpf.
>
> A nice side effect of this model is when the same XDP programs are
> being used in non-Linux environments (HW offload, other OSes, etc.)
> the process could maintain quality expections in those environments
> also.

I'm not against having some 'signed' eBPF/XDP programs.  If a XDP
programs behavior is well-defined enough, this would also open up for
HW offloading of "programs" that does the same functionality (without
looking at the eBPF code).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
