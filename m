From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [softmac-dev] [PATCH] ieee80211_rx_any: filter out packets, call ieee80211_rx or ieee80211_rx_mgt
Date: Thu, 26 Jan 2006 12:25:10 +0200
Message-ID: <200601261225.10506.vda@ilport.com.ua>
References: <20060118200616.GC6583@tuxdriver.com> <1138026752.3957.98.camel@localhost> <20060125154402.GB9224@shaftnet.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>, jbenc@suse.cz,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net,
	linux-kernel@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932281AbWAZK2v@vger.kernel.org>
To: Stuffed Crust <pizza@shaftnet.org>
In-Reply-To: <20060125154402.GB9224@shaftnet.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 25 January 2006 17:44, Stuffed Crust wrote:
> On Mon, Jan 23, 2006 at 03:32:32PM +0100, Johannes Berg wrote:
> > Shouldn't you BSS-filter management packets too?
> 
> Filtering on BSSID is necessary for management frames, especially when 
> multicast management frames are thrown into the mix.  

ieee80211_rx_mgt can do any filtering necessary.

Foreign mgmt packets, if properly used, can provide us with constantly
updated info about local wireless neighborhood: available Ad-hoc
networks and BSSes, signal quality of APs etc. Something resembling
constantly running scan. For example, acx driver does exactly this.

Note that typically mgmt traffic is rather low and processing it
(instead of dropping) won't add much overhead.
 
> For example, STAs are supposed to respect broadcast disassoc/deauth
> messages, but of course should ignore them if they're not destined for
> the local BSSID. 

This filtering can (should) be done in ieee80211_rx_mgt.

> The only extra-BSS management frames that should not be dropped are are
> beacons and probe responses.  That said, probe responses are directed so
> our A1 (RA) filter will probably drop the frame if it is not destined
> for us.
--
vda
