From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 25 Jun 2015 18:01:17 +0300
Message-ID: <CAJ3xEMiyT3tOTO7yr4doutNMsmsrQtX1r2WvjTuTTd7dRzYnoA@mail.gmail.com>
References: <20150624.063911.1220157256743743341.davem@davemloft.net>
	<CA+55aFybr6Fjti5WSm=FQpfwdwgH1Pcfg6L81M-Hd9MzuSHktg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFybr6Fjti5WSm=FQpfwdwgH1Pcfg6L81M-Hd9MzuSHktg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 25, 2015 at 2:38 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Jun 24, 2015 at 6:39 AM, David Miller <davem@davemloft.net> wrote:
> >
> >   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>
> Just going through the conflicts, I see commit 7193a141eb74 ("IB/mlx4:
> Set VF to read from QP counters"), and wonder...
>
> Is that code really supposed to fall through to the
> infiniband-over-ethernet case when the link layer is
> IB_LINK_LAYER_INFINIBAND but it's a slave?
>
> The commit message is not in the least helpful.
>

And this is a bug indeed.

Under IB links, we should use the the infiniband-over-ethernet flow only for one
specific case (reading link performance counters by SRIOV VFs) and nothing else.

I sent a fix, https://patchwork.kernel.org/patch/6675921/

Or.
