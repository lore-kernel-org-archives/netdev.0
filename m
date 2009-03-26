From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix unaligned memory accesses in ASIX
Date: Thu, 26 Mar 2009 01:08:10 -0700 (PDT)
Message-ID: <20090326.010810.23291587.davem@davemloft.net>
References: <1238050359-28415-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755228AbZCZIIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:08:22 -0400
In-Reply-To: <1238050359-28415-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 26 Mar 2009 07:52:39 +0100

> Move in memory all the frames with an incorrect alignment.
> This is to prevent unaligned memory accesses into the upper layers.
> Note 1: this is a penalty for some architecture like SH.
> Note 2: indeed, this patch restores an old one posted three years ago
> (http://marc.info/?l=linux-usb-devel&m=116578791817830&w=2).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

There are some gratuitous (and wrong) changes in here:

> -	u32  header;
 ...
> +	unsigned int header;

It's a u32 whether you like it or not.  Please don't
change away from fixed sized types.

Also isn't there a way we can prefixed what this packet
offset is going to be?  If so, we can adjust the skb_reserve()
call the generic USB net code uses.

Thanks.
