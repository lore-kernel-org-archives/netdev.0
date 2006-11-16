From: "Miles Lane" <miles.lane@gmail.com>
Subject: Re: 2.6.19-rc5-mm2 -- bcm43xx busted (backing out the bcm43xx patches fixes it)
Date: Wed, 15 Nov 2006 21:45:52 -0800
Message-ID: <a44ae5cd0611152145k1af580fcsf0c983934978a241@mail.gmail.com>
References: <a44ae5cd0611141521pd342109jaae9e27aca3d2200@mail.gmail.com>
	 <200611152116.30734.rjw@sisk.pl> <455BCA05.8000007@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Andrew Morton" <akpm@osdl.org>, Bcm43xx-dev@lists.berlios.de,
	"Michael Buesch" <mb@bu3sch.de>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:37519 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161830AbWKPFpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Nov 2006 00:45:54 -0500
Received: by nf-out-0910.google.com with SMTP id o25so868395nfa
        for <netdev@vger.kernel.org>; Wed, 15 Nov 2006 21:45:53 -0800 (PST)
To: "Larry Finger" <Larry.Finger@lwfinger.net>
In-Reply-To: <455BCA05.8000007@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
> Rafael J. Wysocki wrote:
> > On Wednesday, 15 November 2006 00:21, Miles Lane wrote:
> >> Hello,
> >>
> >> The last three MM kernels have fail to give me a working bcm43xx driver.
> >> The odd thing is that dmesg output seems to indicate that the driver
> >> is working okay.  NetworkManager doesn't see the driver, though.
> >> "iwlist scan" fails to find any access points, too.  iwconfig shows
> >> "Access Point: invalid".
> >
> > I can confirm the symptoms, I see them too on my test boxes.
> >
> >> I tried backing out the following patches, and it fixes the problem:
> >>
> >> drivers/net/wireless/bcm43xx/bcm43xx.h
> >> drivers/net/wireless/bcm43xx/bcm43xx_main.c
> >> drivers/net/wireless/bcm43xx/bcm43xx_power.c
> >> drivers/net/wireless/bcm43xx/bcm43xx_wx.c
> >>> drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
>
> The missing patch is shown below. This patch was entitled "[PATCH] bcm43xx: Readd dropped
> assignment" and submitted to wireless-2.6 by Daniel Drake on 10/17/06, but it seems to have fallen
> through the cracks. It is a fix to a patch entitled "[PATCH] ieee80211: Move IV/ICV stripping into
> ieee80211_rx" also submitted by Daniel Drake on 9/26/2006.
>
> NOTE to maintainers: This problem affects BOTH wireless-2.6 and 2.6.19-rcX-mmY. At present, the
> "Move IV/ICV" patch has not been incorporated into 2.6.19-rcX and it is OK.
>
> Larry
>
>
> In the patch sent by Daniel Drake under the title "[PATCH] ieee80211: Move
> IV/ICV stripping into ieee80211_rx", a needed line was accidentally removed.
> As my current copy of wireless-2.6.git does not contain this line, I am
> (re)submitting a patch to restore that line.
>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>
> Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> ===================================================================
> --- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> +++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
> @@ -543,6 +543,7 @@ int bcm43xx_rx(struct bcm43xx_private *b
>                 break;
>         }
>
> +       frame_ctl = le16_to_cpu(wlhdr->frame_ctl);
>         switch (WLAN_FC_GET_TYPE(frame_ctl)) {
>         case IEEE80211_FTYPE_MGMT:
>                 ieee80211_rx_mgt(bcm->ieee, wlhdr, &stats);
>
>

Thanks!  I have verified that this patch solves the problem for me.

      Miles
