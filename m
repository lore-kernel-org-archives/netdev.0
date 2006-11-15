From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Wed, 15 Nov 2006 17:25:01 +0100
Message-ID: <1163607901.2705.53.camel@ux156>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong>  <1161681021.2840.23.camel@ux156>
	 <1161764889.8668.13.camel@devlinux-hong>  <1161766245.2767.17.camel@ux156>
	 <1163470978.7789.31.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34443 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030655AbWKOQYD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 11:24:03 -0500
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1163470978.7789.31.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-11-14 at 10:22 +0800, Hong Liu wrote:
> Resend the patch according to Johannes's comments.

Thanks :)

> Still put he tkip_key in tx_control structure.

Having the tkip_key in there is actually pretty bad for when/if we want
to push the tx_control into skb->cb (possibly combined with some header
or whatever). I don't think that has been decided on yet, will be a
large change anyway and this helps a lot so :)

Instead of putting all this into the stack, however, I think we could
make those drivers that require it do the bookkeeping and export
ieee80211_tkip_gen_phase1key and ieee80211_tkip_gen_rc4key for their
use. Maybe that's too much against Jiri's doctrine of "be easy on
drivers" though :)

This might actually also go some way towards unification with ipw2x00's
ieee80211 because those drivers require such functions as well as far as
I know. Haven't looked too deeply though.

johannes
