From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix unaligned memory accesses in ASIX
Date: Thu, 26 Mar 2009 02:00:18 -0700 (PDT)
Message-ID: <20090326.020018.26561577.davem@davemloft.net>
References: <1238050359-28415-1-git-send-email-peppe.cavallaro@st.com>
	<20090326.010810.23291587.davem@davemloft.net>
	<49CB3F6D.2010508@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42867
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754772AbZCZJAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 05:00:31 -0400
In-Reply-To: <49CB3F6D.2010508@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 26 Mar 2009 09:40:13 +0100

> Unfortunately, unaligned memory accesses seems to depend on the Asix HW
> that packs several incoming frames.
> So when these frames are 'unpacked' within the fix-up function, and
> pushed to the upper layer, they can have a wrong alignment, indeed.
> When no frame is packed all works fine and the IP never works with
> unaligned addresses.
> I think, the skb_reserve could actually help us, if this last scenario
> generated misaligned accesses.
> Please let me know if I'm missing something.

The unpacker is taking a set of packet(s) in a USB buffer
and copying them into SKB's right?  That code should be where
the offset is checked in the child driver, and adjustments
made as-needed.

This code seems to call the downstream driver callback after
the damage is done.  I think it needs to ask the driver to
look for and indicate the offset before the building of the
SKB is performed.
