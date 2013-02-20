From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [E1000-devel] [next:akpm 16/587]
 drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to
 '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON
 failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD + NET_IP_ALIGN +
 IGB_TS_HDR_LEN + ETH...
Date: Wed, 20 Feb 2013 15:02:24 -0800
Message-ID: <1361401344.17413.1.camel@edumazet-glaptop>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com>
	   <20130219142708.b454d98a.akpm@linux-foundation.org>
	   <804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com>
	   <CAL4WiirCCfN_Xi423sEJB5v=5hCR_3d8M26JmmG3VJ=fbH4-1g@mail.gmail.com>
	   <51251303.9030803@intel.com>
	 <1361388156.19353.216.camel@edumazet-glaptop>  <51253ED2.3050605@intel.com>
	 <1361396560.19353.226.camel@edumazet-glaptop> <51255277.2020005@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Daniel Santos <daniel.santos@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:32902 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab3BTXC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 18:02:26 -0500
Received: by mail-pb0-f53.google.com with SMTP id un1so3138755pbc.26
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 15:02:26 -0800 (PST)
In-Reply-To: <51255277.2020005@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 14:47 -0800, Alexander Duyck wrote:

> Huh?  I'm not seeing what you are saying.  The NET_SKB_PAD is the value
> that is in the last set of parenthesis since it was:
> (NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH_FRAME_LEN + ETH_FCS_LEN)
>     that is the bit that became:
> (32 + 2 + 16 + 1514 + 4)
> 
> The problem is the skb_shared_info bit rounds up to 512 reducing the
> available space to 1536.  If you add up all of the other bits ignoring
> the NET_SKB_PAD value you end up with exactly 1536 meaning the only
> value for NET_SKB_PAD that would work is 0.

Oh well, for one moment I thought the SKB_DATA_ALIGN() was also using
NET_SKB_PAD, but its using SMP_CACHE_BYTES.
