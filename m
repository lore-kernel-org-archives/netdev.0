From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7 net-2.6.26] [TIPC]: Force linearization of
 non-linear sk_buffs
Date: Tue, 15 Apr 2008 19:04:24 -0700 (PDT)
Message-ID: <20080415.190424.184937043.davem@davemloft.net>
References: <1208288637-15304-1-git-send-email-allan.stephens@windriver.com>
	<1208288637-15304-7-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46864
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753575AbYDPCE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 22:04:28 -0400
In-Reply-To: <1208288637-15304-7-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Tue, 15 Apr 2008 15:43:56 -0400

> This patch allows TIPC to process incoming messages that are
> stored in a fragmented sk_buff, by forcing the linearization
> of any such messages it receives.
> 
> Note: This is an interim solution to allow TIPC to operate with
> Ethernet devices that generate non-linear buffers (such as the
> gianfar driver), until such time as the rest of TIPC is enhanced
> to handle sk_buffs with multiple data areas.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Applied.

Most of the work will simply be peppering the input paths with
the necessary pskb_may_pull() calls.

The data transfer helpers all understand non-linear SKBs, so
you likely won't need to do much in that area.

In fact it should be very simple to add proper support here.

