From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] iwlwifi: dont pull too much payload in skb
 head
Date: Fri, 18 May 2012 17:21:24 +0200
Message-ID: <1337354484.7029.42.camel@edumazet-glaptop>
References: <1337352513.7029.18.camel@edumazet-glaptop>
	 <1DC40B07CD6EC041A66726C271A73AE61955AE5D@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>
To: "Berg, Johannes" <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37386 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab2ERPV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 11:21:29 -0400
Received: by eeit10 with SMTP id t10so869317eei.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 08:21:28 -0700 (PDT)
In-Reply-To: <1DC40B07CD6EC041A66726C271A73AE61955AE5D@IRSMSX102.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 14:59 +0000, Berg, Johannes wrote:
> > Since merge window is now pretty close, I would prefer David applies this
> > directly in net-next, if you dont mind, as this patch is more a core network issue
> > than an iwlwifi one.
> > 
> > Thanks !
> 
> Sure, good with me, I don't think we have colliding patches.
> 
> Reviewed-by: Johannes Berg <johannes.berg@intel.com>

Thanks

> We may want to move this code into mac80211 later though since it also
> has an if (pull in everything, even reallocating if necessary, if it's
> a management frame), but that can wait, I think we're the only driver
> using paged RX.

This is OK, these frames wont be injected in linux IP/TCP stack.

Or maybe you would like an optimized version of skb_header_pointer(),
avoiding the copy if the whole blob can be part of _one_ fragment ?
