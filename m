From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 2/4] bnx2x: remove not necessary compiler barrier
Date: Wed, 10 Mar 2010 18:00:57 +0200
Message-ID: <1268236857.30985.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1268153703-4186-1-git-send-email-sgruszka@redhat.com>
 <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Stanislaw Gruszka" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3418 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756814Ab0CJQB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 11:01:28 -0500
In-Reply-To: <1268153703-4186-2-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-09 at 08:55 -0800, Stanislaw Gruszka wrote:
> Access to fp->tx_bd_prod is protected by __netif_tx_lock, so we do not
> need any barrier for that.
> 
> Update of fp->tx_bd_cons in bnx2x_tx_int() is not protected by lock, but
> barrier() nor smb_mb() in bnx2x_tx_avail() not guarantee we will see
> values that is written on other cpu. Ordering issues between
> netif_tx_stop_queue(), netif_tx_queue_stopped(), fp->tx_bd_cons = bd_cons
> and bnx2x_tx_avail() are already handled by smp_mb() in bnx2x_tx_int()
> and bnx2x_start_xmit().
> 
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>


