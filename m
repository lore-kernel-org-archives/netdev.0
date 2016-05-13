From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3] udp: Resolve NULL pointer dereference over
 flow-based vxlan device
Date: Thu, 12 May 2016 21:43:33 -0700
Message-ID: <1463114613.23934.180.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
	 <20160512232203.12606.41050.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tgraf@suug.ch, tom@herbertland.com,
	jbenc@redhat.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36060 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbcEMEng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 00:43:36 -0400
Received: by mail-pf0-f196.google.com with SMTP id g132so8336361pfb.3
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 21:43:35 -0700 (PDT)
In-Reply-To: <20160512232203.12606.41050.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-12 at 16:23 -0700, Alexander Duyck wrote:
> While testing an OpenStack configuration using VXLANs I saw the following
> call trace:

> The following trace is seen when receiving a DHCP request over a flow-based
> VXLAN tunnel.  I believe this is caused by the metadata dst having a NULL
> dev value and as a result dev_net(dev) is causing a NULL pointer dereference.
> 
> To resolve this I am replacing the check for skb_dst(skb)->dev with just
> skb->dev.  This makes sense as the callers of this function are usually in
> the receive path and as such skb->dev should always be populated.  In
> addition other functions in the area where these are called are already
> using dev_net(skb->dev) to determine the namespace the UDP packet belongs
> in.
> 
> Fixes: 63058308cd55 ("udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb")
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks ;)
