From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [E1000-devel] [next:akpm 16/587]
 drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to
 '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON
 failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD + NET_IP_ALIGN +
 IGB_TS_HDR_LEN + ETH...
Date: Wed, 20 Feb 2013 11:22:36 -0800
Message-ID: <1361388156.19353.216.camel@edumazet-glaptop>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com>
	 <20130219142708.b454d98a.akpm@linux-foundation.org>
	 <804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com>
	 <CAL4WiirCCfN_Xi423sEJB5v=5hCR_3d8M26JmmG3VJ=fbH4-1g@mail.gmail.com>
	 <51251303.9030803@intel.com>
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
Received: from mail-da0-f45.google.com ([209.85.210.45]:62977 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934775Ab3BTTWk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 14:22:40 -0500
Received: by mail-da0-f45.google.com with SMTP id v40so185136dad.4
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 11:22:39 -0800 (PST)
In-Reply-To: <51251303.9030803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-20 at 10:16 -0800, Alexander Duyck wrote:

> 
> The problem is the 256 byte alignment for L1_CACHE_BYTES is increasing
> the size of the data and shared info significantly pushing us past the
> 2K limit.
> 
> I'll look into this since it likely affects ixgbe as well.

Thats what I said.

Using 256 bytes of headroom is silly.

We should limit NET_SKB_PAD to the 32-64 range
