From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Mon, 7 Sep 2015 23:52:51 +0200
Message-ID: <20150907215251.GA4897@electric-eye.fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
 <20150907144412.GA26524@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60799 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbIGVxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 17:53:24 -0400
Content-Disposition: inline
In-Reply-To: <20150907144412.GA26524@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> I have a bit of a problem with this patch.  It crashes when loading the
> driver manually w/ modprobe.  For some reason dev_get_stats is called
> during rtl_init_one and at that time the counters pointer is NULL, so
> the kernel gets a SEGV.
>
>  After I worked around that I got a SEGV in
> rtl_remove_one, which I still have to find out why.  I didn't test with
> the latest kernel, though, so I still have to check if that's the reason
> for the crashes.  That takes a bit longer, I just wanted to let you
> know.

Call me stupid: I forgot that it's perfectly fine to request the stats
of a down interface. :o/

Updated patch is on the way.

> There's also a problem with rtl8169_cmd_counters:  It always calls
> rtl_udelay_loop_wait_low w/ rtl_reset_counters_cond, even when called
> from rtl8169_update_counters, where it should call
> rtl_udelay_loop_wait_low w/ rtl_counters_cond to check for the
> CounterDump flag, rather than for the CounterReset flag.
> 
> For now I applied the below patch, but I think it's a bit ugly to
> conditionalize the rtl_cond struct by the incoming flag value.

<captain obvious>

Let's check both at once:

	return RTL_R32(CounterAddrLow) & (CounterDump | CounterReset);

</captain obvious>

Thanks for reviewing.

-- 
Ueimor
