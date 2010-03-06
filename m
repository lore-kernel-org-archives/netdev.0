From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Sat, 06 Mar 2010 19:47:56 +0100
Message-ID: <m2vdd9p9r7.fsf@ssh.synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<201003030156.o231udx1023055@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201003030156.o231udx1023055@www262.sakura.ne.jp> (Tetsuo Handa's
	message of "Wed, 03 Mar 2010 10:56:39 +0900")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Regarding [RFC v2 09/10] snet: introduce snet_ticket
> +enum snet_verdict snet_ticket_check(struct snet_info *info)
> +{
> +       struct snet_ticket *st = NULL;
> +       unsigned int h = 0, verdict = SNET_VERDICT_NONE;
> +       struct list_head *l = NULL;
> +       struct snet_task_security *tsec = NULL;
> +
> +       if (snet_ticket_mode == SNET_TICKET_OFF)
> +               goto out;
> +
> +       tsec = (struct snet_task_security*) current_security();
> +
> +       h = jhash_2words(info->syscall, info->protocol, 0) % HSIZE;
> +       l = &tsec->hash[h];
> +
> +       read_lock_bh(&tsec->lock);
>
> Credentials are allocated for copy-on-write basis.
> Sharing "tsec" among multiple "struct task_struct" is what you intended?

No, there is no shared "tsec".
snet_ticket_check() is called from the process context. So "tsec" is
a pointer to the "void *security" pointer from its own "struct
task_struct".

every task_struct have a "tsec" allocated to its "void *security"
pointer. 

I will take a second look on how to access the credentials COW.

> Regards.

Tetsuo, thank you again for reviewing.
sam
