From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH V2 3/8] netback: switch to NAPI + kthread model
Date: Tue, 17 Jan 2012 09:07:30 -0800
Message-ID: <20120117090730.13ae3c6e@nehalam.linuxnetplumber.net>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
	<1326808024-3744-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, konrad.wilk@oracle.com,
	david.vrabel@citrix.com, paul.durrant@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48898 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755120Ab2AQRHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 12:07:36 -0500
In-Reply-To: <1326808024-3744-4-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Jan 2012 13:46:59 +0000
Wei Liu <wei.liu2@citrix.com> wrote:

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
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

The network receive processing is sensitive to the context it is run in.
Normally it is run in softirq with interrupts enabled. With your code,
the poll routine disables IRQ's which shouldn't be necessary.

Why does xenvif_receive_skb() need to still exist? Couldn't it
just be replaced with call to netif_receive_skb() in one place it is called.
