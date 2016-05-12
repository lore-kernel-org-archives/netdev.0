From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] udp: Resolve NULL pointer dereference
Date: Wed, 11 May 2016 20:43:08 -0700
Message-ID: <1463024588.23934.158.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160512022306.3691.40769.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33326 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751552AbcELDnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 23:43:11 -0400
Received: by mail-pf0-f195.google.com with SMTP id y7so5214687pfb.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 20:43:11 -0700 (PDT)
In-Reply-To: <20160512022306.3691.40769.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-11 at 19:24 -0700, Alexander Duyck wrote:
> While testing an OpenStack configuration using VXLANs I saw the following
> call trace:

> 
> I believe the trace is pointing to the call to dev_net(dev) in
> udp4_lib_lookup_skb.  If I am not mistaken I believe it is possible for us
> to have skb_dst(skb)->dev be NULL.  So to resolve that I am adding a check
> for this case and skipping the assignment if such an event occurs.

skb_dst(skb)->dev can be NULL ???

Why only UDP ipv4 would need a fix, and not ipv6 ?

Looks the bug is somewhere else maybe ?
