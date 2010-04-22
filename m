From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Socket filter ancilliary data access for skb->dev->type
Date: Thu, 22 Apr 2010 14:28:46 +0200
Message-ID: <4BD040FE.3000809@trash.net>
References: <20100422121253.GR19334@cel.leo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65032 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab0DVM2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 08:28:49 -0400
In-Reply-To: <20100422121253.GR19334@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul LeoNerd Evans wrote:
> Add an SKF_AD_HATYPE field to the packet ancilliary data area, giving
> access to skb->dev->type, as reported in the sll_hatype field.
> 
> When capturing packets on a PF_PACKET/SOCK_RAW socket bound to all
> interfaces, there doesn't appear to be a way for the filter program to
> actually find out the underlying hardware type the packet was captured
> on. This patch adds such ability.
> 
> +		case SKF_AD_HATYPE:
> +			A = skb->dev->type;
> +			continue;

I think we should be adding a check whether skb->dev is non-NULL here
since filters can also be attached to netlink sockets. The same applies
to SKF_AD_IFINDEX.
