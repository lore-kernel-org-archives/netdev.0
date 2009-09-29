From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] connector: Fix sid connector (was: Badness at
	kernel/softirq.c:143...)
Date: Tue, 29 Sep 2009 15:59:59 +0200
Message-ID: <20090929135959.GA6806@redhat.com>
References: <200909251123.03482.borntraeger@de.ibm.com> <fbbbe0a028fa.4ac1f1c0@2ka.mipt.ru> <20090929132415.GB4538@redhat.com> <200909291547.21528.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeny Polyakov <johnpol@2ka.mipt.ru>,
	Scott James Remnant <scott@ubuntu.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Matt Helsley <matthltc@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752601AbZI2OEX@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200909291547.21528.borntraeger@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29, Christian Borntraeger wrote:
>
> --- linux-2.6.orig/kernel/sys.c
> +++ linux-2.6/kernel/sys.c
> @@ -1110,6 +1110,8 @@ SYSCALL_DEFINE0(setsid)
>  	err = session;
>  out:
>  	write_unlock_irq(&tasklist_lock);
> +	if (!err)
> +		proc_sid_connector(sid);

sys_setsid() returns the session nr on success, not zero.

	if (err > 0)
		proc_sid_connector(sid);

Otherwize I think the patch is fine. Not only it should fix the problem,
imho it makes the code cleaner.

If Scott still thinks daemonize() should report too, we can change it.

(I'd suggest you to CC Andrew if you are going to re-send)

Oleg.
