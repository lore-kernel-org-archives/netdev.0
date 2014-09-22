From: Emil Goode <emilgoode@gmail.com>
Subject: Re: [PATCH] brcmfmac: Fix off by one bug in
 brcmf_count_20mhz_channels()
Date: Tue, 23 Sep 2014 00:38:32 +0200
Message-ID: <20140922223832.GA10356@lianli>
References: <1411253932-27973-1-git-send-email-emilgoode@gmail.com>
 <541FF0C4.9020805@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Daniel Kim <dekim@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <541FF0C4.9020805@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Arend,

Ok I will resend with your ack.

Best regards,

Emil

On Mon, Sep 22, 2014 at 11:49:56AM +0200, Arend van Spriel wrote:
> On 09/21/14 00:58, Emil Goode wrote:
> >In the brcmf_count_20mhz_channels function we are looping through a list
> >of channels received from firmware. Since the index of the first channel
> >is 0 the condition leads to an off by one bug. This is causing us to hit
> >the WARN_ON_ONCE(1) calls in the brcmu_d11n_decchspec function, which is
> >how I discovered the bug.
> >
> >Introduced by:
> >commit b48d891676f756d48b4d0ee131e4a7a5d43ca417
> >("brcmfmac: rework wiphy structure setup")
> 
> My bad :-(. You can add:
> 
> Acked-by: Arend van Spriel <arend@broadcom.com>
> >Signed-off-by: Emil Goode<emilgoode@gmail.com>
> >---
> >  drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> >index 02fe706..93b5dd9 100644
> >--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> >+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> >@@ -4918,7 +4918,7 @@ static void brcmf_count_20mhz_channels(struct brcmf_cfg80211_info *cfg,
> >  	struct brcmu_chan ch;
> >  	int i;
> >
> >-	for (i = 0; i<= total; i++) {
> >+	for (i = 0; i<  total; i++) {
> >  		ch.chspec = (u16)le32_to_cpu(chlist->element[i]);
> >  		cfg->d11inf.decchspec(&ch);
> >
> 
