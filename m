From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V5 6/7] xen-netback: coalesce slots in TX path and fix
 regressions
Date: Wed, 17 Apr 2013 14:53:21 +0100
Message-ID: <1366206801.25579.47.camel@zakaz.uk.xensource.com>
References: <1366045581-31349-1-git-send-email-wei.liu2@citrix.com>
	 <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:16243 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966116Ab3DQNxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 09:53:24 -0400
In-Reply-To: <1366045581-31349-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-15 at 18:06 +0100, Wei Liu wrote:
> This patch tries to coalesce tx requests when constructing grant copy
> structures. It enables netback to deal with situation when frontend's
> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> 
> With the help of coalescing, this patch tries to address two regressions and
> avoid reopening the security hole in XSA-39.
> 
> Regression 1. The reduction of the number of supported ring entries (slots)
> per packet (from 18 to 17). This regression has been around for some time but
> remains unnoticed until XSA-39 security fix. This is fixed by coalescing
> slots.
> 
> Regression 2. The XSA-39 security fix turning "too many frags" errors from
> just dropping the packet to a fatal error and disabling the VIF. This is fixed
> by coalescing slots (handling 18 slots when backend's MAX_SKB_FRAGS is 17)
> which rules out false positive (using 18 slots is legit) and dropping packets
> using 19 to `max_skb_slots` slots.
> 
> To avoid reopening security hole in XSA-39, frontend sending packet using more
> than max_skb_slots is considered malicious.
> 
> The behavior of netback for packet is thus:
> 
>     1-18            slots: valid
>    19-max_skb_slots slots: drop and respond with an error
>    max_skb_slots+   slots: fatal error
> 
> max_skb_slots is configurable by admin, default value is 20.
> 
> Also change variable name from "frags" to "slots" in netbk_count_requests.
> 
> Please note that RX path still has dependency on MAX_SKB_FRAGS. This will be
> fixed with separate patch.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
