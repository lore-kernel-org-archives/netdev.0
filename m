From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 3/3] mac80211: mesh: fixed HT ies in beacon template
Date: Tue, 02 Aug 2016 09:27:17 +0200
Message-ID: <1470122837.2665.5.camel@sipsolutions.net>
References: <20160713200755.26839-1-yanivma@ti.com>
 <40a34537-486e-a466-5a7e-e253f19d81c3@gmail.com>
 <1470045822.3389.24.camel@sipsolutions.net>
 <75fef3ce-41a6-5845-e9be-d7ff052a07da@gmail.com>
	 <1c2d3cfc-b7fd-c8fd-4f74-14dd3aa3076e@gmail.com>
	 (sfid-20160802_045911_090360_06FDF780)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org,
	Meirav Kama <meiravk@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Masashi Honma <masashi.honma@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1c2d3cfc-b7fd-c8fd-4f74-14dd3aa3076e@gmail.com> (sfid-20160802_045911_090360_06FDF780)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-08-02 at 11:59 +0900, Masashi Honma wrote:
> > 
> > On 2016年08月01日 19:03, Johannes Berg wrote:
> > > 
> > > But why is that behaviour *correct*? We still support 40 MHz
> > > bandwidth
> > > things, we just don't use them if we disable HT40.
> 
> Or do you mean difference between "hardware capability" and "software
> capability" ?
> Do you think IEEE80211_HT_CAP_SUP_WIDTH_20_40 bit should be 1 if the 
> hardware capable of HT40 even though HT40 is disabled by 
> wpa_supplicant/hostapd ?

I basically think that the CAP_SUP_WIDTH_20_40 bit shouldn't matter at
all, so it's not clear to me why there's so much talk about it.

After all, if 40 MHz isn't actually *used* as indicated by the HT
operation (rather than HT capability) IE, then the fact that the device
may or may not support 40 MHz is pretty much irrelevant.

> I have tested with hostapd. I compared these 2 configfiles.
> 
> hostapd0.conf
> 	ht_capab=[HT40-]
> hostapd1.conf
> 	#ht_capab=[HT40-]
> 

This explicitly configures *HT capability* though - that's even the
name of the parameter. If you enable HT40 in the capability, the
resulting BSS might still not actually *use* 40 MHz bandwidth, as
required by overlapping BSS detection.

In this patch, they're taking one thing (current HT channel width
configuration) and applying it to another thing (HT capability), and
then even selling it as a bugfix - which I simply cannot understand.
The HT capability shouldn't matter at all, if HT operation is correct.

johannes
