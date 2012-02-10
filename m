From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix driver features
Date: Fri, 10 Feb 2012 02:40:33 -0500 (EST)
Message-ID: <20120210.024033.1496479783120497956.davem@davemloft.net>
References: <1328784993-31733-1-git-send-email-peppe.cavallaro@st.com>
	<20120209.153504.92022308276431620.davem@davemloft.net>
	<4F34C286.2070304@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098Ab2BJHkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 02:40:39 -0500
In-Reply-To: <4F34C286.2070304@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 10 Feb 2012 08:08:54 +0100

> Hello David
> 
> On 2/9/2012 9:35 PM, David Miller wrote:
>> This is not the purpose of the fix_features method, it's meant to
>> ensure that the settings are valid.
>> 
>> It's not meant to "catch up" with settings you store in the internal
>> datastructures of your driver.
>> 
>> You need to do this at probe time, where the initial ->hw_features
>> and ->features values are set.
> 
> Initially the driver HW features are indeed set in the probe but in the
> stmmac_open function, after looking at the HW cap reg, some parameters,
> for example the HW csum, can be overridden and the
> netdev_update_features is called. IIUC the netdev_update_features calls
> the driver's ndo_fix_features. For this reason I improved the
> stmmac_fix_feature function to cover more setting. Anyway, if I cannot
> use this function I should move from the open to the probe the logic to
> manage the MAC identification and HW cap register. What do you suggest?

You should not be determining chip features in your open method,
such work belongs in your device probe.
