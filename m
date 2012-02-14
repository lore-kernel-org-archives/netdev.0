From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Question with commit 299b0767(ipv6: Fix IPsec slowpath
 fragmentation problem)
Date: Tue, 14 Feb 2012 12:04:14 +0100
Message-ID: <20120214110414.GA31660@secunet.com>
References: <4F38C57F.5000706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45948 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759664Ab2BNLES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Feb 2012 06:04:18 -0500
Content-Disposition: inline
In-Reply-To: <4F38C57F.5000706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2012 at 04:10:39PM +0800, Li Wei wrote:
> Hi, Steffen!
> 
> I found some problem while doing networking tests with IPSec that
> the first fragment doesn't use the max MTU to fill payload, but with
> 20 bytes smaller. When I reverted your commit 299b0767(ipv6: Fix 
> IPsec slowpath fragmentation problem), things goes well.
> 
> Would you so kindly to point me out what the commit did, because I
> think the original implementation had taken IPSec header and tailer
> into account.
> 

Without this patch we used always the slow path in ip6_fragment()
due to a miscalculation of the packet lenght in ip6_append_data().

This patch just makes use of the reduced IPsec mtu, and adapts
the IPsec header handling to have enought headroom on the skb.
