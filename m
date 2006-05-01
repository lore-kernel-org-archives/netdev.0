From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: IP1000 gigabit nic driver
Date: Mon, 1 May 2006 22:38:47 +0200
Message-ID: <20060501203847.GA7419@electric-eye.fr.zoreil.com>
References: <20060428075725.GA18957@fargo> <84144f020604280358ie9990c7h399f4a5588e575f8@mail.gmail.com> <20060428113755.GA7419@fargo> <Pine.LNX.4.58.0604281458110.19801@sbz-30.cs.Helsinki.FI> <1146306567.1642.3.camel@localhost> <20060429122119.GA22160@fargo> <1146342905.11271.3.camel@localhost> <1146389171.11524.1.camel@localhost> <44554ADE.8030200@cantab.net> <4455F1D8.5030102@cantab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34279 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932239AbWEAUjt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 16:39:49 -0400
To: David Vrabel <dvrabel@cantab.net>
Content-Disposition: inline
In-Reply-To: <4455F1D8.5030102@cantab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Vrabel <dvrabel@cantab.net> :
[...]
> It was clocking the MII management interface (MDC) at 500 Hz so each PHY
> register access took some 130 ms, and many registers accesses were being
> done on initialization. According to the datasheet, the maximum
> frequency for MDC is 2.5 MHz.  Delays have been adjusted accordingly.

[...]
> Index: linux-source-2.6.16/drivers/net/ipg.h
> ===================================================================
> --- linux-source-2.6.16.orig/drivers/net/ipg.h	2006-05-01 12:08:58.343035854 +0100
> +++ linux-source-2.6.16/drivers/net/ipg.h	2006-05-01 12:09:37.282602113 +0100
> @@ -672,10 +672,10 @@
>  /* Number of IPG_AC_RESETWAIT timeperiods before declaring timeout. */
>  #define         IPG_AC_RESET_TIMEOUT         0x0A
>  
> -/* Minimum number of miliseconds used to toggle MDC clock during
> +/* Minimum number of nanoseconds used to toggle MDC clock during
>   * MII/GMII register access.
>   */
> -#define         IPG_PC_PHYCTRLWAIT           0x01
> +#define		IPG_PC_PHYCTRLWAIT_NS		200

I would have expected a cycle of 400 ns (p.72/77 of the datasheet)
for a 2.5 MHz clock. Why is it cut by a two factor ?

-- 
Ueimor
