From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v5 4/9] bgmac: simplify rx DMA error handling
Date: Tue, 14 Apr 2015 01:20:40 +0200
Message-ID: <20150413232040.GA30799@electric-eye.fr.zoreil.com>
References: <1428946067-75650-1-git-send-email-nbd@openwrt.org>
 <1428946067-75650-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, zajec5@gmail.com, hauke@hauke-m.de
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42565 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbDMXUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 19:20:55 -0400
Content-Disposition: inline
In-Reply-To: <1428946067-75650-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Felix Fietkau <nbd@openwrt.org> :
> Unmap the DMA buffer before checking it. If an error occurs, free the
> buffer and allocate a new one. If allocation or mapping fails, retry as
> long as there is NAPI poll budget left (count every attempt instead of
> every frame).

The driver is not supposed to use the NAPI budget this way.

If the driver can't reserve resources to handle the packet, it should
drop the data, keep everything in place for the hardware and move to the
next slot.

-- 
Ueimor
