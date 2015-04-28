From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Mon, 27 Apr 2015 22:57:09 -0400 (EDT)
Message-ID: <20150427.225709.1737864122610182544.davem@davemloft.net>
References: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbD1C5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 22:57:11 -0400
In-Reply-To: <1430183690-24198-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Mon, 27 Apr 2015 18:14:50 -0700

> Commit commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated memory
> allocation in the packet send path. This commit introduced a bug since it
> did not account for the case if the skb was cloned. Fix this bug by
> using the pre-reserved head room only if the skb is not cloned.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

We have generic infrastructure to do this, please try instead:

	err = skb_cow_head(skb, pkt_sz);

this will take care of everything for you and you can get rid
of all of this dynamic memory allocation etc. in this code
path.
