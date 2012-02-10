From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: fix driver features
Date: Fri, 10 Feb 2012 08:08:54 +0100
Message-ID: <4F34C286.2070304@st.com>
References: <1328784993-31733-1-git-send-email-peppe.cavallaro@st.com> <20120209.153504.92022308276431620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:35649 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751915Ab2BJHJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:09:02 -0500
In-Reply-To: <20120209.153504.92022308276431620.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David

On 2/9/2012 9:35 PM, David Miller wrote:
> This is not the purpose of the fix_features method, it's meant to
> ensure that the settings are valid.
> 
> It's not meant to "catch up" with settings you store in the internal
> datastructures of your driver.
> 
> You need to do this at probe time, where the initial ->hw_features
> and ->features values are set.

Initially the driver HW features are indeed set in the probe but in the
stmmac_open function, after looking at the HW cap reg, some parameters,
for example the HW csum, can be overridden and the
netdev_update_features is called. IIUC the netdev_update_features calls
the driver's ndo_fix_features. For this reason I improved the
stmmac_fix_feature function to cover more setting. Anyway, if I cannot
use this function I should move from the open to the probe the logic to
manage the MAC identification and HW cap register. What do you suggest?

Many thanks for you review
Regards
Peppe
