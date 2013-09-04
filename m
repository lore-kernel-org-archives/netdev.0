From: Dave Jones <davej@redhat.com>
Subject: rtl8188eu array/null comparison.
Date: Wed, 4 Sep 2013 19:30:18 -0400
Message-ID: <20130904233018.GB5727@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry.Finger@lwfinger.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756476Ab3IDXa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 19:30:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Larry,

in drivers/staging/rtl8188eu/core/rtw_mlme.c:rtw_check_join_candidate there's this code..

1721         /* check ssid, if needed */
1722         if (pmlmepriv->assoc_ssid.Ssid && pmlmepriv->assoc_ssid.SsidLength) {
1723                 if (competitor->network.Ssid.SsidLength != pmlmepriv->assoc_ssid.SsidLength ||
1724                     _rtw_memcmp(competitor->network.Ssid.Ssid, pmlmepriv->assoc_ssid.Ssid, pmlmepriv->assoc_ssid.SsidLength) == false)
1725                         goto exit;
1726         }
1727 

assoc_ssid.Ssid being an array, this comparison against null probably isn't what was intended ?

	Dave
