From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC v2] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 14:42:39 -0800
Message-ID: <20091117144239.47930866@nehalam>
References: <1258465585.3682.7.camel@johannes.local>
	<1258490898.21197.42.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51549 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755857AbZKQWmy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 17:42:54 -0500
In-Reply-To: <1258490898.21197.42.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 21:48:18 +0100
Johannes Berg <johannes@sipsolutions.net> wrote:

> A number of people have tried to add a wireless interface
> (in managed mode) to a bridge and then complained that it
> doesn't work. It cannot work, however, because in 802.11
> networks all packets need to be acknowledged and as such
> need to be sent to the right address. Promiscuous doesn't
> help here. The wireless address format used for these
> links has only space for three addresses, the
>  * transmitter, which must be equal to the sender (origin)
>  * receiver (on the wireless medium), which is the AP in
>    the case of managed mode
>  * the recipient (destination), which is on the APs local
>    network segment
> 
> In an IBSS, it is similar, but the receiver and recipient
> must match and the third address is used as the BSSID.
> 
> To avoid such mistakes in the future, disallow adding a
> wireless interface to a bridge.
> 
> Felix has recently added a four-address mode to the AP
> and client side that can be used (after negotiating that
> it is possible, which must happen out-of-band by setting
> up both sides) for bridging, so allow that case.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Looks good, maybe true four-address mode support will be available
more widely, and this will no longer be an issue.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>
