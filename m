From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: fix occasional BUG during MTU change
Date: Tue, 14 Apr 2009 15:17:05 -0700 (PDT)
Message-ID: <20090414.151705.43540582.davem@davemloft.net>
References: <20090407183623.7545bb0b@leela>
	<20090414105539.6388f677@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754932AbZDNWRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 18:17:14 -0400
In-Reply-To: <20090414105539.6388f677@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 14 Apr 2009 10:55:39 -0700

> On Tue, 7 Apr 2009 18:36:23 +0200
> Michal Schmidt <mschmidt@redhat.com> wrote:
> 
>> The BUG_ON(skge->tx_ring.to_use != skge->tx_ring.to_clean) in skge_up()
>> was sometimes observed when setting MTU.
>> 
>> skge_down() disables the TX queue, but then reenables it by mistake via
>> skge_tx_clean().
>> Fix it by moving the waking of the queue from skge_tx_clean() to the
>> other caller. And to make sure start_xmit is not in progress on another
>> CPU, skge_down() should call netif_tx_disable().
>> 
>> The bug was reported to me by Jiri Jilek whose Debian system sometimes
>> failed to boot. He tested the patch and the bug did not happen anymore.
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>> ---
>>  drivers/net/skge.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> Tested fine. This should go to stable as well.
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks everyone.
