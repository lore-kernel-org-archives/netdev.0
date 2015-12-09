From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Wed, 9 Dec 2015 14:04:22 +0100
Message-ID: <20151209130422.GB9900@pox.localdomain>
References: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
 <20151208.214411.2137019448940208712.davem@davemloft.net>
 <56679B2F.5080700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36587 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbLINEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 08:04:24 -0500
Received: by wmww144 with SMTP id w144so221340641wmw.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 05:04:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56679B2F.5080700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/15 at 08:08pm, David Ahern wrote:
> On 12/8/15 7:44 PM, David Miller wrote:
> >Unfortunately it's too late for this, you should have considered this
> >issue fully when VRF first went into an upstream release.
> >
> >If I add your change, the user experience is _worse_.
> >
> >Users on older kernels have to use the full sequence, then if they
> >upgrade their kernels to one with this patch then the 'ru add' et
> >al. commands will fail.
> >
> 
> Perhaps this is another fug (feature bug), they do not fail:
> 
> root@kenny-jessie2:~# ip ru ls
> 0:	from all lookup local
> 32760:	from all iif vrf-green lookup vrf-green
> 32761:	from all oif vrf-green lookup vrf-green
> 32762:	from all iif vrf-blue lookup vrf-blue
> 32763:	from all oif vrf-blue lookup vrf-blue
> 32764:	from all iif vrf-red lookup vrf-red
> 32765:	from all oif vrf-red lookup vrf-red
> 32766:	from all lookup main
> 32767:	from all lookup default
> 
> root@kenny-jessie2:~# ip ru add oif vrf-red lookup vrf-red

This is not a bug. FIB rules can include forward jumps so it's
perfectly valid to have the same rule in the entire chain
multiple times. Just like it is for iptables and multiple chains.
