From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b
 drivers
Date: Mon, 15 May 2006 13:37:25 +0200
Message-ID: <20060515133725.3df090af@griffin.suse.cz>
References: <200605042232.35446.flamingice@sourmilk.net>
	<200605101331.39960.flamingice@sourmilk.net>
	<20060512124703.563dacd6@griffin.suse.cz>
	<200605121635.27959.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Jouni Malinen" <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:54457 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964888AbWEOLh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 07:37:28 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200605121635.27959.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 May 2006 16:35:27 -0400, Michael Wu wrote:
> Hm, so why not add something that will tell you what modes are supported by 
> the hardware?

Sounds reasonable.

> Only problem with this patch is if the hardware adds any modes after 
> registration, they will be disabled initially. Hopefully, no drivers will 
> actually need to do that.

bcm43xx does that. If I understand it correctly, bcm43xx driver doesn't
know allowed modes until it loads firmware. And the firmware is not
loaded until the device is opened (they probably have a reason for
this).

This issue can be easily solved by not masking hw_modes by
valid_hw_modes in ieee80211_ioctl_prism2_param and
ieee80211_precalc_modes. Just check (hw_modes & valid_hw_modes) instead
of hw_modes in ieee80211_sta_scan_timer.

And yes, hw_modes is a confusing name. It should be named
hw_modes_mask_disabled_by_user or so. Maybe at least some better comment
about this in ieee80211_i.h won't be a bad idea.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
