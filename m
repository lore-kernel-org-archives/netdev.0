From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/3] d80211: Add control structure for beacontemplates
Date: Mon, 5 Feb 2007 21:28:02 +0100
Message-ID: <20070205212802.36477fd4@griffin.suse.cz>
References: <200702031725.19080.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45325 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933269AbXBEU2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 15:28:05 -0500
In-Reply-To: <200702031725.19080.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 3 Feb 2007 17:25:18 +0100, Ivo van Doorn wrote:
> When rt2500usb and rt73usb will start using beacontemplates,
> they would also need a control structure to be passed along to
> correctly set the tx parameters.

Good catch, thanks.

> This patch will add the allocation an initialization of a
> ieee80211_tx_control especially for the beacontemplate.
> 
> This does require drivers that have the BEACON_TEMPLATE flag
> set to also free the control structure. (bcm43xx and p54 will be
> fixed in the next 2 patches)

I would prefer using local variable for tx_control. Driver will be
responsible for copying it somewhere if it needs to. I believe most
drivers won't need to do that and it will prevent potential memory
leaks as it's easy to forget to free the structure.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
