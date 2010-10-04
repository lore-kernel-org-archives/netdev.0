From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: normalize frag_list usage
Date: Mon, 04 Oct 2010 11:32:58 -0700 (PDT)
Message-ID: <20101004.113258.212671454.davem@davemloft.net>
References: <20101003.235400.229759758.davem@davemloft.net>
	<4CAA1722.7070405@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53615
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932178Ab0JDSch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 14:32:37 -0400
In-Reply-To: <4CAA1722.7070405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 04 Oct 2010 11:04:18 -0700

> This will not work for RSC due to the fact that it assumes only one
> RSC context is active per ring and that is not the case.  There can be
> multiple RSC combined flows interlaced on the ring.

Thanks for looking at this Alexander.

I must have mis-understood what the current code is doing.

It looked like RSC packets always show up in-order in the RX ring.

And that they are scanned for by simply combining any sequence of
non-EOP packets up to and including the final EOP one into a frag
list.

Are the RSC packets are identified via something else entirely?
