From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Date: Tue, 24 Aug 2004 20:17:33 +0100
Sender: linux-ia64-owner@vger.kernel.org
Message-ID: <20040824201733.B32110@infradead.org>
References: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com> <20040824182344.GB13961@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ia64@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-ia64-owner@vger.kernel.org>
To: Dean Nelson <dcn@sgi.com>
Content-Disposition: inline
In-Reply-To: <20040824182344.GB13961@sgi.com>; from dcn@sgi.com on Tue, Aug 24, 2004 at 01:23:44PM -0500
List-Id: netdev.vger.kernel.org

On Tue, Aug 24, 2004 at 01:23:44PM -0500, Dean Nelson wrote:
> This patch contains the shim module (XP) which interfaces between the
> communication module (XPC) and the functional support modules (like XPNET).
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>
> 
> 
> Index: linux/arch/ia64/Kconfig
> ===================================================================
> --- linux.orig/arch/ia64/Kconfig	2004-08-17 13:31:26.000000000 -0500
> +++ linux/arch/ia64/Kconfig	2004-08-23 11:39:50.000000000 -0500
> @@ -189,6 +189,16 @@
>  	depends on !IA64_HP_SIM
>  	default y
>  
> +config IA64_SGI_SN_XPC
> +	tristate "Support DMA Messaging between SGI machines"

Why do you have three different option when the only way they're usefull
is to have all three enabled at the same time.  Also as I mentioned previously
please merge at least xp and xpc into a single module.

> +	depends on FETCHOP

Please make sure the fetchop driver is at least posted publically
before submitting anything that depends on it.

> +xp-y				:= xp_main.o xp_kdb.o xp_nofault.o

Please kill all the kdb hooks for mainline submission.

> +	case xpcMsgReceived:		return "xpcMsgReceived";
> +	case xpcMsgDelivered:		return "xpcMsgDelivered";

Please don't add strerror-lookalikes to the kernel.

> +	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
> +		sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
> +	}

A single mutex wouldn't do it?  It doesn't exactly look like it's used in
fast-paths

> +	 */
> +	if ((ret = sn_register_nofault_code(*(u64 *) pior_func,
> +					*(u64 *) pior_err_func,
> +					*(u64 *) pior_err_func, 1, 1)) != 0) {

Is the strange casting really unavoidable?

