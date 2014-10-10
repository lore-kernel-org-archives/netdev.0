From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 08:36:16 -0700
Message-ID: <1412955376.9362.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	 <20141010145647.23006.54451.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:49325 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918AbaJJPgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 11:36:18 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so1850087pde.34
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 08:36:17 -0700 (PDT)
In-Reply-To: <20141010145647.23006.54451.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-10 at 07:59 -0700, alexander.duyck@gmail.com wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> 
> This patch addresses a kernel unaligned access bug seen on a sparc64 system
> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
> be32 pointer which was then having the value directly returned.
> 
> In order to keep the handling of the ports consistent with how we were
> handling the IPv4 and IPv6 addresses I have instead replaced the assignment
> with a memcpy to the flow key ports value.  This way it should stay a
> memcpy on systems that cannot handle unaligned access, and will likely be
> converted to a 32b assignment on the systems that can support it.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---

I believe you also need to take care of calls to ipv6_addr_hash()

The IPv4 part also needs something in iph_to_flow_copy_addrs(),
otherwise compiler might assume  &iph->saddr is word aligned.
