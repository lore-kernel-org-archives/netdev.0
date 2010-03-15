From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] bnx2x: remove not necessary compiler barrier
Date: Mon, 15 Mar 2010 15:47:29 -0700 (PDT)
Message-ID: <20100315.154729.41966662.davem@davemloft.net>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
	<1268153703-4186-2-git-send-email-sgruszka@redhat.com>
	<1268236857.30985.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, vladz@broadcom.com,
	mchan@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34476
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937007Ab0COWrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:47:08 -0400
In-Reply-To: <1268236857.30985.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 10 Mar 2010 18:00:57 +0200

> On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
>> Access to fp->tx_bd_prod is protected by __netif_tx_lock, so we do not
>> need any barrier for that.
>> 
>> Update of fp->tx_bd_cons in bnx2x_tx_int() is not protected by lock, but
>> barrier() nor smb_mb() in bnx2x_tx_avail() not guarantee we will see
>> values that is written on other cpu. Ordering issues between
>> netif_tx_stop_queue(), netif_tx_queue_stopped(), fp->tx_bd_cons = bd_cons
>> and bnx2x_tx_avail() are already handled by smp_mb() in bnx2x_tx_int()
>> and bnx2x_start_xmit().
>> 
>> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
