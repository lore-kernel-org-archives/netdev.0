From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 3/6] netback: switch to NAPI + kthread
 model
Date: Fri, 13 Jan 2012 18:21:25 +0000
Message-ID: <4F107625.7090601@citrix.com>
References: <1326473949-22389-1-git-send-email-wei.liu2@citrix.com> <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<xen-devel@lists.xensource.com>, <netdev@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55638 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181Ab2AMSV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 13:21:27 -0500
In-Reply-To: <1326473949-22389-4-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/01/12 16:59, Wei Liu wrote:
> This patch implements 1:1 model netback. We utilizes NAPI and kthread
> to do the weight-lifting job:
> 
>   - NAPI is used for guest side TX (host side RX)
>   - kthread is used for guest side RX (host side TX)
> 
> This model provides better scheduling fairness among vifs. It also
> lays the foundation for future work.
> 
> The major defect for the current implementation is that in the NAPI
> poll handler we don't actually disable interrupt. Xen stuff is
> different from real hardware, it requires some other tuning of ring
> macros.

RING_FINAL_CHECK_FOR_REQUESTS() looks it does the correct thing to me.

David
