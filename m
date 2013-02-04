From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v9 net-next 00/12] Add basic VLAN support to bridges
Date: Mon, 04 Feb 2013 11:58:38 -0500
Message-ID: <510FE8BE.4040302@redhat.com>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com> <20130204082409.422ba135@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753308Ab3BDQ6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2013 11:58:42 -0500
In-Reply-To: <20130204082409.422ba135@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2013 11:24 AM, Stephen Hemminger wrote:
> One thing I am not clear about is whether is supposed to be just
> a simple filter of VLAN traffic, or a full VLAN aware bridge.

I started with the concept of basic VLAN filtering, but it has been 
morphing into more of a VLAN away bridge.

>
> The change to make FDB entries per-VLAN seems to be the biggest tipping
> point into a full VLAN bridge. I am concerned that might break existing
> API's and Spanning Tree (internal and external).
>

I debated for a while about whether per-VLAN FDB entries were needed. 
The typing point was that without it, you may end up with flopping FDB 
and possible packet drops or vlan leaks, if say 2 different VMs used the 
same MAC but different VLANs.  Without it, there is an exploitable gap.

I've also tried to separate FDB code changes as much as possible.  If 
you really thing this is a big risk and a barrier to entry, then we can 
drop them.  I am just concerned about the hole I described above, but I 
guess it is not much different then what's there now.

Thanks
-vlad
