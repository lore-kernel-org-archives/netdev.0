From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] netfilter: default to NF_DROP in sip_help_tcp()
Date: Wed, 14 Jul 2010 14:23:01 +0200
Message-ID: <4C3DAC25.3050401@trash.net>
References: <20100710031604.GA26990@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab0GNMW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:22:59 -0400
In-Reply-To: <20100710031604.GA26990@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.07.2010 05:16, Simon Horman wrote:
> I initially noticed this because of the compiler warning below, but it does
> seem to be a valid concern in the case where ct_sip_get_header() returns 0
> in the first iteration of the while loop.
> 
> net/netfilter/nf_conntrack_sip.c: In function 'sip_help_tcp':
> net/netfilter/nf_conntrack_sip.c:1379: warning: 'ret' may be used uninitialized in this function

Thanks Simon. I've applied the patch, but changed NF_DROP to
NF_ACCEPT since we should avoid dropping packets with unknown
contents (not SIP) if possible.
