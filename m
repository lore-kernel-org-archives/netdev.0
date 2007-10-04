From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 compile breakage: error: 'ipgre_header' undeclared
Date: Thu, 04 Oct 2007 15:11:08 -0700 (PDT)
Message-ID: <20071004.151108.82373575.davem@davemloft.net>
References: <47055FD6.5070801@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756135AbXJDWLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 18:11:09 -0400
In-Reply-To: <47055FD6.5070801@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Date: Thu, 04 Oct 2007 14:49:10 -0700

> I'm getting this on net-2.6.24 today:
> 
>   CC [M]  net/ipv4/ip_gre.o
> net/ipv4/ip_gre.c:1135: error: 'ipgre_header' undeclared here (not in a function)
> make[2]: *** [net/ipv4/ip_gre.o] Error 1
> make[1]: *** [net/ipv4] Error 2
> make[1]: *** Waiting for unfinished jobs....
> 
> 
> the git log says sch touched it last:

Please us Stephen's current email address if you really want to reach
him :) It was even mentioned in the commit sign off.  I've fixed it up
in the CC:

>     [NET]: Move hardware header operations out of netdevice.
> 
>     Since hardware header operations are part of the protocol class
>     not the device instance, make them into a separate object and
>     save memory.
> 
>     Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Stephen, we need to handle the case where NET_IPGRE_BROADCAST is
not enabled.  ipgre_header() is only compiled in when that is
set, but you reference it unconditionally.
