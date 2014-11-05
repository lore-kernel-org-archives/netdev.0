From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCHv2 net-next] xen-netback: remove unconditional
 __pskb_pull_tail() in guest Tx path
Date: Wed, 5 Nov 2014 10:57:42 +0000
Message-ID: <1415185062.11486.85.camel@citrix.com>
References: <1415184622-19421-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:58567 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754126AbaKEK5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 05:57:45 -0500
In-Reply-To: <1415184622-19421-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 10:50 +0000, David Vrabel wrote:
> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> 
> Unconditionally pulling 128 bytes into the linear area is not required
> for:
> 
> - security: Every protocol demux starts with pskb_may_pull() to pull
>   frag data into the linear area, if necessary, before looking at
>   headers.
> 
> - performance: Netback has already grant copied up-to 128 bytes from
>   the first slot of a packet into the linear area. The first slot
>   normally contain all the IPv4/IPv6 and TCP/UDP headers.

Thanks for adding these.

> The unconditional pull would often copy frag data unnecessarily.  This
> is a performance problem when running on a version of Xen where grant
> unmap avoids TLB flushes for pages which are not accessed.  TLB
> flushes can now be avoided for > 99% of unmaps (it was 0% before).
> 
> Grant unmap TLB flush avoidance will be available in a future version
> of Xen (probably 4.6).
> 
> Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>
