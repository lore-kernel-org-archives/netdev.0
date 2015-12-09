From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: thunderx: Correctly distinguish between VF and
 LMAC count
Date: Tue, 08 Dec 2015 22:45:19 -0500 (EST)
Message-ID: <20151208.224519.806579181027596160.davem@davemloft.net>
References: <009701d1318b$54357620$fca06260$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	sunil.kovvuri@gmail.com, youngmin.lee@cavium.com,
	kin-yip.liu@cavium.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbbLIDpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:45:21 -0500
In-Reply-To: <009701d1318b$54357620$fca06260$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Tue, 08 Dec 2015 10:37:44 +0300

> Commit bc69fdfc6c13
> ("net: thunderx: Enable BGX LMAC's RX/TX only after VF is up")
> introduces lmac_cnt member and starts verifying VF number against it.
> This is plain wrong, and works only because currently we have hardcoded
> 1:1 mapping between VFs and LMACs, and in this case num_vf_en and
> lmac_cnt are always equal. However in future this may change, and the
> code will badly misbehave. The worst consequence of this is failure to
> deliver link status messages, causing VFs to go defunct because since
> commit 0b72a9a1060e ("net: thunderx: Switchon carrier only upon
> interface link up") VF will not fully bring itself up without it.
> 
> This patch fixes the potential problem by doing VF number checks against
> the num_vf_en. Since lmac_cnt is not used anywhere else, it is removed.
> 
> Additionally some duplicated code is factored out into nic_enable_vf()
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

Applied.
