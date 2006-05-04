From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Add support for user space client
 MLME
Date: Thu, 4 May 2006 11:00:28 +0200
Message-ID: <20060504110028.5af3a22a@griffin.suse.cz>
References: <20060503164458.GB10524@instant802.com>
	<20060503201059.58477ea6@griffin.suse.cz>
	<20060503183524.GD10524@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:211 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751446AbWEDJAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 05:00:30 -0400
To: "Jouni Malinen" <jkm@devicescape.com>
In-Reply-To: <20060503183524.GD10524@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 May 2006 11:35:24 -0700, Jouni Malinen wrote:
> I think it would be nice to get this in so that both client and AP modes
> can use the same mechanism (user space MLME); hostapd already needs this
> wmaster0ap interface. In other words, if we do not want to see that
> interface by default, we could just add a generic mechanism for
> registering wmaster0ap that both hostapd and wpa_supplicant could use.
> The Host AP driver (driver/net/wireless/hostap) is doing this with
> PRISM2_PARAM_HOSTAPD parameter. I don't care how it's done, but some
> simple mechanism would be preferred.

Ok. So what about PRISM2_HOSTAPD_MGMT_IF ioctl that will add management
interface (if not added yet) and return its ifindex? It would accept a
boolean parameter (like PRISM2_PARAM_HOSTAPD) to add/remove that
interface. If you agree with this, I will make a patch.

Of course, both hostapd and wpa_supplicant needs to be changed for that.
This should not be a problem now as the d80211 stack is not in a common
use yet.

> No, move of MLME to user space should not change this at all. As an
> example, wpa_supplicant supports both cases and the patch I'm working on
> for getting Prism2 (full MAC for client mode) working with d80211 is
> modifying the kernel side to allow this to be done. Both changes are
> touching the same areas in the code, but there is no major change in
> whether fullmac can be supported or not.

So wpa_supplicant needs to know if the card is softmac or fullmac and
behave accordingly, right?

> That is not up-to-date with wireless-dev.git anymore, though. The key
> patch is d80211_fullmac_client.diff which is small enough to include
> here. Please note that this is not yet complete, so consider it more an
> example on what type of changes are needed.

Oh, thanks, now I remember, I have seen that.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
