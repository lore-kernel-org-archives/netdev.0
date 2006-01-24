From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [Bcm43xx-dev] Re: [softmac-dev] [PATCH] ieee80211_rx_any: filter out packets, call ieee80211_rx or ieee80211_rx_mgt
Date: Tue, 24 Jan 2006 10:06:10 +0200
Message-ID: <200601241006.10372.vda@ilport.com.ua>
References: <20060118200616.GC6583@tuxdriver.com> <200601221404.52757.vda@ilport.com.ua> <1138026752.3957.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>, jbenc@suse.cz,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030363AbWAXIHp@vger.kernel.org>
To: bcm43xx-dev@lists.berlios.de
In-Reply-To: <1138026752.3957.98.camel@localhost>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 23 January 2006 16:32, Johannes Berg wrote:
> On Sun, 2006-01-22 at 14:04 +0200, Denis Vlasenko wrote:
> > +       hdr = (struct ieee80211_hdr_4addr *)skb->data;: 
> > +       fc = le16_to_cpu(hdr->frame_ctl);: 
> > +: 
> > +       switch (fc & IEEE80211_FCTL_FTYPE) {: 
> > +       case IEEE80211_FTYPE_MGMT: 
> > +               ieee80211_rx_mgt(ieee, hdr, stats);: 
> > +               return 0;: 
> 
> Shouldn't you BSS-filter management packets too?
> 
> > +       is_packet_for_us = 0;: 
> > +       switch (ieee->iw_mode) {: 
> > +       case IW_MODE_ADHOC: 
> > +               /* promisc: get all */
> > +               if (ieee->dev->flags & IFF_PROMISC): 
> > +                       is_packet_for_us = 1;
> 
> And I still think BSS-filtering is correct even in the promisc case. Any
> other opinions why either way is right or not? [I think we should filter
> because upper layers won't know the packet wasn't for us if it was
> broadcast in another BSSID]

In wired networks promisc literally means "receive all packets", right?

But for wireless, maybe we should filter them out, or else running tcpdump
on the iface will force us to listen to ARP packets from unrelated networks.
That would be rather surprising and disrupting.
--
vda
