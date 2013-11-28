From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] xen-netback: fix fragment detection in checksum
 setup
Date: Thu, 28 Nov 2013 09:29:05 -0800
Message-ID: <1385659745.5352.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1385645032-29848-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:43855 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab3K1R3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 12:29:07 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so12844008pbb.23
        for <netdev@vger.kernel.org>; Thu, 28 Nov 2013 09:29:06 -0800 (PST)
In-Reply-To: <1385645032-29848-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-28 at 13:23 +0000, Paul Durrant wrote:
> The code to detect fragments in checksum_setup() was missing for IPv4 and
> too eager for IPv6. (It transpires that Windows seems to send IPv6 packets
> with a fragment header even if they are not a fragment - i.e. offset is zero,
> and M bit is not set).

> +	/* 3fff -> fragment offset != 0 OR more fragments */
> +	if (ntohs(iph->frag_off) & 0x3fff)
> +		fragment = true;
> +

What about the more self documented and faster :

if (iph->frag_off & htons(IP_OFFSET | IP_MF))
	fragment = true;
