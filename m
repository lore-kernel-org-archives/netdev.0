From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Submission for S2io 10GbE driver
Date: Mon, 16 Feb 2004 16:16:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040216161631.7abdd99b@dell_ss3.pdx.osdl.net>
References: <20040205004952.GA27510@cup.hp.com>
	<000201c3f4d2$2a5ddd90$7410100a@S2IOtech.com>
	<20040217001111.A23086@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Leonid Grossman <leonid.grossman@s2io.com>, netdev@oss.sgi.com,
        "'Andi
 Kleen'" <ak@suse.de>, "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Francois
 Romieu'" <romieu@fr.zoreil.com>,
        "'jamal'" <hadi@cyberus.ca>, "'Grant
 Grundler'" <iod00d@hp.com>,
        "'Anton Blanchard'" <anton@samba.org>,
        "'Jes
 Sorensen'" <jes@trained-monkey.org>,
        raghavendra.koushik@s2io.com,
        "'ravinandan arakali'" <ravinandan.arakali@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040217001111.A23086@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2004 00:11:12 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> A bunch of comments:
> 
>  - if you want to submit the driver for inclusion please submit a patch against a kernel tree,
>    not a tarball.
>  - please try to avoid version ifdefs by provoding the newer APIs on older kernels, e.g.:
> 
> #ifndef IRQ_RETVAL
> #define irqreturn_t                     void
> #define IRQ_RETVAL(foo)
> #endif
> 
> #if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,00)
> #define free_netdev kfree
> #endif

The proper way for that is:

#ifndef HAVE_FREE_NETDEV
#define free_netdev(x)  kfree(x)
#endif
