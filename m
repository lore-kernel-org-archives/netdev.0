From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.4] back port msleep(),
	msleep_interruptible()
Date: Sat, 30 Oct 2004 18:41:10 -0400
Message-ID: <41841886.2080609@pobox.com>
References: <20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<415CD9D9.2000607@pobox.com> <20041030222228.GB1456@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
	linux-kernel@vger.kernel.org, hvr@gnu.org,
	Margit Schubert-While <margitsw@t-online.de>,
	kernel-janitors@lists.osdl.org,
	Nishanth Aravamudan <nacc@us.ibm.com>, prism54-devel@prism54.org,
	Domen Puncer <domen@coderock.org>
Return-path: <prism54-devel-bounces@prism54.org>
To: maximilian attems <janitor@sternwelten.at>
In-Reply-To: <20041030222228.GB1456@stro.at>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

maximilian attems wrote:
> diff -puN include/linux/delay.h~add-msleep-2.4 include/linux/delay.h
> --- a/include/linux/delay.h~add-msleep-2.4	2004-10-30 22:48:46.000000000 +0200
> +++ b/include/linux/delay.h	2004-10-30 22:48:46.000000000 +0200
> @@ -34,4 +34,12 @@ extern unsigned long loops_per_jiffy;
>  	({unsigned long msec=(n); while (msec--) udelay(1000);}))
>  #endif
>  
> +void msleep(unsigned int msecs);
> +unsigned long msleep_interruptible(unsigned int msecs);
> +
> +static inline void ssleep(unsigned int seconds)
[...]
> +static inline unsigned int jiffies_to_msecs(const unsigned long j)

> +static inline unsigned int jiffies_to_usecs(const unsigned long j)

> +static inline unsigned long msecs_to_jiffies(const unsigned int m)


I'm pretty sure more than one of these symbols clashes with a symbol 
defined locally in a driver.  I like the patch but we can't apply it 
until the impact on existing code is evaluated.

	Jeff
