From: Daniel Walker <dwalker@codeaurora.org>
Subject: RE: [PATCH] net: Fix race condition on receive path.
Date: Fri, 05 Mar 2010 15:44:27 -0800
Message-ID: <1267832667.30393.16.camel@c-dwalke-linux.qualcomm.com>
References: <1267817699.30393.8.camel@c-dwalke-linux.qualcomm.com>
	 <20100305132118.1855617a@nehalam>
	 <E7C319BA4F818B4BA98B1D6626E5321603261A1F03@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Smith, Alan" <agsmith@quicinc.com>
To: "Harford, Jim" <c_jharfo@quicinc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:38542 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407Ab0CEXok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 18:44:40 -0500
In-Reply-To: <E7C319BA4F818B4BA98B1D6626E5321603261A1F03@NASANEXMB10.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-03-05 at 15:41 -0800, Harford, Jim wrote:
> It appears that this patch is no longer necessary.  It was made against 2.6.29, but I see that more recent kernel versions don't have the problem code.  For a more detailed explanation, see below.  All code references are in routine process_backlog(), file net/core/dev.c.
> 
> In kernel version 2.6.27.45, __napi_complete() is invoked BEFORE interrupts are re-enabled.  Thus, the receive queue status is cleaned up before another interrupt (due to a receive packet) can occur.  This is good design.
> 
> In kernel version 2.6.29, git commit ID 303c6a025 inverts this ordering.  Routine napi_complete() is invoked AFTER interrupts are re-enabled.  We observed interrupts taken after interrupts were re-enabled, but before napi_complete cleaned up the receive queue.  This would then shut down the processing of subsequent received packets.
> 
> In kernel versions 2.6.30.10 and later, the sequence of operations is identical to 2.6.27.45, so there is no problem.
> 
> Jim Harford
> Qualcomm Innovation Center

Ok, I guess we can ignore this one then.

Daniel

