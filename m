From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Fix panic in bnx2_poll_work().
Date: Wed, 06 May 2009 16:47:36 -0700 (PDT)
Message-ID: <20090506.164736.36849446.davem@davemloft.net>
References: <1241630636-21999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pmjdebruijn@pcode.nl,
	hnoefer@pironet-ndh.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43713
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752248AbZEFXrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:47:40 -0400
In-Reply-To: <1241630636-21999-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 6 May 2009 10:23:56 -0700

> Add barrier() to bnx2_get_hw_{tx|rx}_cons() to fix this issue:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=12698
> 
> This issue was reported by multiple i386 users.  Without barrier(),
> the compiled code looks like the following where %eax contains the
> address of the tx_cons or rx_cons in the DMA status block.  The
> status block contents can change between the cmpb and the movzwl
> instruction.  The driver would crash if the value was not 0xff during
> the cmpb instruction, but changed to 0xff during the movzwl
> instruction.
 ...
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Fair enough, applied, thanks!
