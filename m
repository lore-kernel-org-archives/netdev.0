From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 02/14 v2] usb/net: rndis: break out <linux/rndis.h>
 defines
Date: Wed, 25 Apr 2012 19:44:47 -0400 (EDT)
Message-ID: <20120425.194447.1519804940735129000.davem@davemloft.net>
References: <1335367808-4254-1-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org, jussi.kivilinna-E01nCVcF24I@public.gmane.org,
	haiyangz-0li6OtcxBFHby3iVrkZq2A@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org
To: linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335367808-4254-1-git-send-email-linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Linus Walleij" <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Date: Wed, 25 Apr 2012 17:30:08 +0200

> As a first step to consolidate the RNDIS implementations, break out
> a common file with all the #defines and move it to <linux/rndis.h>.
> The compilation screams about double-defines all over the place
> (as could be expected, this is why we're consolidating) but it
> compiles cleanly still.
> 
> Signed-off-by: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

After this patch the build emits tons of warnings because you've
left a situation where there will be duplicate definitions:

In file included from drivers/net/hyperv/hyperv_net.h:30:0,
                 from drivers/net/hyperv/netvsc_drv.c:41:
include/linux/rndis.h:93:0: warning: "OID_GEN_CURRENT_PACKET_FILTER" redefined [enabled by default]
include/linux/rndis.h:51:0: note: this is the location of the previous definition
include/linux/rndis.h:239:0: warning: "RNDIS_STATUS_SUCCESS" redefined [enabled by default]
 ...

This is unacceptable, the tree must build cleanly and work properly at
each step in the patch series, in order to ensure bisectability.  You
can't "fix it up" in a patch later in the series and just assume that
the whole series is applied.

Also, in the new file you created you added a spurious empty line at
the end of the file.  Please remove that as GIT notices this when
applying your patch and thus warns about it.

In fact, please go through this entire patch set (like I was) making
sure the build is clean and no bugs or bisectability issues are
introduced each step of the way.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
