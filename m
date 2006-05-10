From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b drivers
Date: Wed, 10 May 2006 13:31:39 -0400
Message-ID: <200605101331.39960.flamingice@sourmilk.net>
References: <200605042232.35446.flamingice@sourmilk.net> <20060511175426.72ae7744@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Jouni Malinen" <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:52894 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1750787AbWEKVOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 17:14:06 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060511175426.72ae7744@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 11 May 2006 11:54, Jiri Benc wrote:
> On Thu, 4 May 2006 22:32:35 -0400, Michael Wu wrote:
> > This makes the current hack used to prevent 802.11g cards from scanning
> > with 802.11b channels not break scanning in 802.11b drivers.
>
> I think this should be better:
>
I think this is overkill to fix a hack. IMHO, scan_skip_11b shouldn't exist in 
the first place. One alternative would be to modify 802.11g drivers to not 
set IEEE80211_CHAN_W_SCAN on 802.11b channels when there are equivalent 
802.11g channels. Another would be to set the local->hw_modes bitfield 
correctly during driver initialization instead of relying on userspace to set 
it, so the existing logic for avoiding 802.11b channels when 802.11g is 
supported actually works.

Hmm... that ioctl for changing the hw_modes bitfield doesn't seem too good.. 
No validity checking at all .. but then again, the current value of hw_modes 
isn't valid to begin with. It seems like hw_modes is more useful for saying 
what modes shouldn't be used than saying what modes are supported by the 
hardware and should be used.

-Michael Wu
