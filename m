From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH] wl12xx: fix size of two memset's in
 wl1271_cmd_build_arp_rsp()
Date: Thu, 03 May 2012 15:56:41 +0300
Message-ID: <1336049801.12189.31.camel@cumari.coelho.fi>
References: <alpine.LNX.2.00.1204222252000.27455@swampdragon.chaosbits.net>
	 <alpine.LNX.2.00.1204222255460.27455@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204222255460.27455@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2012-04-22 at 22:57 +0200, Jesper Juhl wrote:
> On Sun, 22 Apr 2012, Jesper Juhl wrote:
> 
> > We currently do this:
> > 
> > int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
> > ...
> > 	struct wl12xx_arp_rsp_template *tmpl;
> > 	struct ieee80211_hdr_3addr *hdr;
> > ...
> > 	tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
> > 	memset(tmpl, 0, sizeof(tmpl));
> > ...
> > 	hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
> > 	memset(hdr, 0, sizeof(*hdr));
> > ...
> > 
> > I believe we want to set the entire structures to 0 with those
> > memset() calls, not just zero the initial part of them (size of the
> > pointer bytes).
> > 
> 
> Sorry, I accidentally copied that code from the fixed version. The above 
> should read:
> 
> 
> We currently do this:
> 
> int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
> ...
>       struct wl12xx_arp_rsp_template *tmpl;
>       struct ieee80211_hdr_3addr *hdr;
> ...
>       tmpl = (struct wl12xx_arp_rsp_template *)skb_put(skb, sizeof(*tmpl));
>       memset(tmpl, 0, sizeof(tmpl));
> ...
>       hdr = (struct ieee80211_hdr_3addr *)skb_push(skb, sizeof(*hdr));
>       memset(hdr, 0, sizeof(hdr));
> ...
> 
> I believe we want to set the entire structures to 0 with those
> memset() calls, not just zero the initial part of them (size of the
> pointer bytes).
> 
> 
> 
> 
> 
> > Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> > ---

Applied with the fixed commit log and merged into the new directory
structure.  Thanks Jesper!
