From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: IPv4: sysctl table check failed [was: mmotm 2010-10-07-14-08
 uploaded]
Date: Thu, 7 Oct 2010 15:28:06 -0700
Message-ID: <20101007152806.119d1522.akpm@linux-foundation.org>
References: <201010072140.o97Le69i025659@imap1.linux-foundation.org>
	<4CAE4479.6010606@gmail.com>
	<1286490135.6536.75.camel@edumazet-laptop>
Reply-To: linux-kernel@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <mm-commits-owner@vger.kernel.org>
In-Reply-To: <1286490135.6536.75.camel@edumazet-laptop>
Sender: mm-commits-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 08 Oct 2010 00:22:15 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le vendredi 08 octobre 2010 __ 00:06 +0200, Jiri Slaby a __crit :
> > On 10/07/2010 11:08 PM, akpm@linux-foundation.org wrote:
> > > The mm-of-the-moment snapshot 2010-10-07-14-08 has been uploaded to
> > 
> > Hi, I got bunch of "sysctl table check failed" below. All seem to be
> > related to ipv4:
> 
> I would say, sysctl check is buggy :(
> 
> min/max are optional
> 
> [PATCH] sysctl: min/max bounds are optional
> 
> sysctl check complains when proc_doulongvec_minmax or
> proc_doulongvec_ms_jiffies_minmax are used by a vector of longs (with
> more than one element), with no min or max value specified.
> 
> This is unexpected, given we had a bug on this min/max handling :)
> 
> Reported-by: Jiri Slaby <jirislaby@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  kernel/sysctl_check.c |    9 ---------
>  1 file changed, 9 deletions(-)
> 
> diff --git a/kernel/sysctl_check.c b/kernel/sysctl_check.c
> index 04cdcf7..10b90d8 100644
> --- a/kernel/sysctl_check.c
> +++ b/kernel/sysctl_check.c
> @@ -143,15 +143,6 @@ int sysctl_check_table(struct nsproxy *namespaces, struct ctl_table *table)
>  				if (!table->maxlen)
>  					set_fail(&fail, table, "No maxlen");
>  			}
> -			if ((table->proc_handler == proc_doulongvec_minmax) ||
> -			    (table->proc_handler == proc_doulongvec_ms_jiffies_minmax)) {
> -				if (table->maxlen > sizeof (unsigned long)) {
> -					if (!table->extra1)
> -						set_fail(&fail, table, "No min");
> -					if (!table->extra2)
> -						set_fail(&fail, table, "No max");
> -				}
> -			}
>  #ifdef CONFIG_PROC_SYSCTL
>  			if (table->procname && !table->proc_handler)
>  				set_fail(&fail, table, "No proc_handler");

That will probably fix it ;)

net-avoid-limits-overflow.patch is dependent on this patch.  Unless
Eric B squeaks I'll plan on sending this patch in for 2.6.37.

