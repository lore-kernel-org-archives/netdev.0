From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v4] xen-netback: Fix grant ref resolution in RX path
Date: Thu, 15 May 2014 11:37:49 +0100
Message-ID: <1400150269.4386.30.camel@kazak.uk.xensource.com>
References: <1400148514-2921-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <david.vrabel@citrix.com>,
	<davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:7039 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752396AbaEOKhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 06:37:52 -0400
In-Reply-To: <1400148514-2921-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 11:08 +0100, Zoltan Kiss wrote:
> The original series for reintroducing grant mapping for netback had a patch [1]
> to handle receiving of packets from an another VIF. Grant copy on the receiving
> side needs the grant ref of the page to set up the op.
> The original patch assumed (wrongly) that the frags array haven't changed. In
> the case reported by Sander, the sending guest sent a packet where the linear
> buffer and the first frag were under PKT_PROT_LEN (=128) bytes.
> xenvif_tx_submit() then pulled up the linear area to 128 bytes, and ditched the
> first frag. The receiving side had an off-by-one problem when gathered the grant
> refs.
> This patch fixes that by checking whether the actual frag's page pointer is the
> same as the page in the original frag list. It can handle any kind of changes on
> the original frags array, like:
> - removing granted frags from the array at any point
> - adding local pages to the frags list anywhere
> - reordering the frags
> It's optimized to the most common case, when there is 1:1 relation between the
> frags and the list, plus works optimal when frags are removed from the end or
> the beginning.
> 
> [1]: 3e2234: xen-netback: Handle foreign mapped pages on the guest RX path
> 
> Reported-by: Sander Eikelenboom <linux@eikelenboom.it>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

(Remind me, do we need both this and Eric's fix, or is it either/or?)
