From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 source routing patch is still broken?
Date: Thu, 26 Apr 2007 15:31:42 -0700 (PDT)
Message-ID: <20070426.153142.57441302.davem@davemloft.net>
References: <46311F76.9040803@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753309AbXDZWbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 18:31:35 -0400
In-Reply-To: <46311F76.9040803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Thu, 26 Apr 2007 17:53:58 -0400

> Looking at the patch that went into 2.6.20.9, I can't see
> how type 2 packets get through at all. Shouldn't this part
> read:
> 
> +       case IPV6_SRCRT_TYPE_2:
> +               if (accept_source_route >= 0)
> +                       break;
> +               kfree_skb(skb);
> +               return -1;
> +       case IPV6_SRCRT_TYPE_0:
> +               if (accept_source_route > 0)
> +                       break;
> +               kfree_skb(skb);
> +               return -1;

Yes, that looks like it matches the sysctl documentation more closely:

accept_source_route - INTEGER
	Accept source routing (routing extension header).

	> 0: Accept routing header.
	= 0: Accept only routing header type 2.
	< 0: Do not accept routing header.

Type 2 packets should get through as long as the value of the sysctl
is not negative.

Hmmm?
