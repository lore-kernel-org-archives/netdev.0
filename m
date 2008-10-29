From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 10:01:01 +0100
Message-ID: <4908264D.4030206@trash.net>
References: <490824B3.20100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60292 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561AbYJ2JBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 05:01:05 -0400
In-Reply-To: <490824B3.20100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> This patch make HTB update class's bstats in one place when dequeuing
> packets instead of updating the leaf's when enqueuing and updating the
> other's when dequeuing. It also fixes a statistics bug, the statistics
> data of leaf class will exceeds its parent classes's due to packets are
> dropped by its inner qdisc.

They should actually all be updated in enqueue. The estimators needs
this since they're estimating the arrival rate.

