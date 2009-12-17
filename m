From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Security: Implement prctl(PR_SET_NETWORK, PR_NETWORK_OFF) semantics.
Date: Thu, 17 Dec 2009 11:18:22 -0800
Message-ID: <m1pr6dwgsh.fsf@fess.ebiederm.org>
References: <1260977452-2334-1-git-send-email-michael@laptop.org>
	<1260977565-2379-2-git-send-email-michael@laptop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Drepper <drepper@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	"Andi Kleen" <andi@firstfloor.org>, "David Lang" <david@lang.hm>,
	"Oliver Hartkopp" <socketcan@hartkopp.net>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Valdis Kletnieks" <Valdis.Kletnieks@vt.edu>,
	"Bryan Donlan" <bdonlan@gmail.com>,
	"Evgeniy Polyakov" <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"James Morris" <jmorris@namei.org>,
	"Bernie Innocenti" <bernie@codewiz.org>,
	"Mark Seaborn" <mrs@mythic-beasts.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1260977565-2379-2-git-send-email-michael@laptop.org> (Michael Stone's message of "Wed\, 16 Dec 2009 10\:32\:44 -0500")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Stone <michael@laptop.org> writes:

> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 23bd09c..5b38db0 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -151,6 +151,8 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  		dumpable = get_dumpable(task->mm);
>  	if (!dumpable && !capable(CAP_SYS_PTRACE))
>  		return -EPERM;
> +	if (current->network)
> +		return -EPERM;

The principle should be: you gain no privileges by ptracing.
Therefore this check should be:

	if (current->network && !task->network)
		return -EPERM;

Which keeps the ptrace logic from being a larger hammer than it needs
to be.

Eric
