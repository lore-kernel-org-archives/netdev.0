From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH-next v2 3/4] net/sched: make sch_blackhole.c explicitly
 non-modular
Date: Thu, 8 Oct 2015 18:59:59 -0400
Message-ID: <20151008225959.GN14103@windriver.com>
References: <1444253266-22012-1-git-send-email-paul.gortmaker@windriver.com>
 <1444253266-22012-4-git-send-email-paul.gortmaker@windriver.com>
 <CAHA+R7PgVBptnzzcWFW+9bp9UL40e+V+4K8PJjrF-KzeFQodQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34969 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbbJHXAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 19:00:05 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7PgVBptnzzcWFW+9bp9UL40e+V+4K8PJjrF-KzeFQodQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH-next v2 3/4] net/sched: make sch_blackhole.c explicitly non-modular] On 07/10/2015 (Wed 14:47) Cong Wang wrote:

> On Wed, Oct 7, 2015 at 2:27 PM, Paul Gortmaker
> <paul.gortmaker@windriver.com> wrote:
> > The Kconfig currently controlling compilation of this code is:
> >
> > net/sched/Kconfig:menuconfig NET_SCHED
> > net/sched/Kconfig:      bool "QoS and/or fair queueing"
> >
> > ...meaning that it currently is not being built as a module by anyone.
> 
> Is there any reason why sch_blackhole can't be a module like
> other qdisc's?
> 
> If not, I'd rather making it be a module. It is small but not often used.

As I've said in other similar threads, there are some 300+ places
where code that can't ever be modular uses modular calls and/or
introduces dead module remove code.

Hence here I am making the code consistent with its current limitations.
I'm not looking to extend functionality in code that I don't know
intimately.  I can't do that and do it reliably and guarantee it
works as a module when it has never been used as such before in 300+
places all across the kernel.

If there are interested users who want their code tristate and can vouch
that their code works OK as such, I can drop the patch(es) here ; this
is what happened with 4 of the patches I originally had in v1 of this
very series.  But a good number of the 300+ instances have been this way
since before git history began (2005) and so I wonder the value in say
extending instances like old ISA drivers from bool to tristate...

Paul.
--
