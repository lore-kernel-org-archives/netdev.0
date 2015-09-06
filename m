From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 3/3] r8169: increase the lifespan of the hardware
 counters dump area.
Date: Sun, 6 Sep 2015 22:21:53 +0200
Message-ID: <20150906202153.GB19371@electric-eye.fr.zoreil.com>
References: <cover.1441454454.git.romieu@fr.zoreil.com>
 <fb3db9039225ed3a030e779565b8e11f99fc8ae2.1441454454.git.romieu@fr.zoreil.com>
 <20150906103732.GF30539@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58896 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbbIFUWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 16:22:21 -0400
Content-Disposition: inline
In-Reply-To: <20150906103732.GF30539@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
> On Sep  5 14:18, romieu@fr.zoreil.com wrote:
[...]
> > - rtl_reset_counters_cond induced failures in open() are also considered
> >   fatal: it takes acceptable work to unwind comfortably.
> 
> Why?


Crap, my description does not match the code wrt rtl_reset_counters_cond. :o/

s/rtl8169_reset_counters/rtl8169_update_counters/g

The code is right.

[...]
> This returns -EINVAL even for older chip versions which are not capable
> of resetting the counters.  The result is, this driver will not work at
> all on chip versions prior to RTL_GIGA_MAC_VER_19 anymore, because
> rtl_open will always fail.

No. My changelog was misleading. rtl_init_counter_offsets handles this part
correctly.

-- 
Ueimor
