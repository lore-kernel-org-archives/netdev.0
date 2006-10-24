From: Hong Liu <hong.liu@intel.com>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Tue, 24 Oct 2006 16:38:54 +0800
Message-ID: <1161679134.7258.6.camel@devlinux-hong>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42091 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1030223AbWJXIpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 04:45:44 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1161678908.2840.12.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 16:35, Johannes Berg wrote:
> On Tue, 2006-10-24 at 16:20 +0800, Hong Liu wrote:
> 
> > It's really strange bcm43xx only does phase2 mixing in hw. With all the
> > code that does phase2 mixing, doing phase1 mixing is very cheap.
> 
> Yeah, well, they have the tkip sbox in hw.
> 
> > With Jiri's ieee80211_tx_ctrl_common patch, I think we can put the
> > rc4key or phase1 key in ieee80211_tx_control with each TX packet.
> 
> No, the phase1 key is not dependent on the packet so it should not be
> there. It should be set via the regular key setting mechanism, instead
> of the TKIP key the driver would be given the phase1 key if required.
> 
> johannes

The first time when we set the TKIP key, we can set the phase1 key if
the driver requires.
The problem is when IV16 wraps, who will generate the new phase1 key?
If the stack need to do this, then we will need to call set_key in the
packet TX path which I think may not be appropriate.

Thanks,
Hong
