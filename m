From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: ip tunnel: fix multiple routes with
 different encap
Date: Tue, 18 Aug 2015 19:11:35 -0700 (PDT)
Message-ID: <20150818.191135.1217710280336001449.davem@davemloft.net>
References: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
	<fe9cdcf34e26de1e9107f964c3e6612dcaf13662.1439916029.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbbHSCLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 22:11:35 -0400
In-Reply-To: <fe9cdcf34e26de1e9107f964c3e6612dcaf13662.1439916029.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 18 Aug 2015 18:42:09 +0200

> Currently, two routes going through the same tunnel interface are considered
> the same even when they are routed to a different host after encapsulation.
> This causes all routes added after the first one to have incorrect
> encapsulation parameters.
> 
> This is nicely visible by doing:
> 
>   # ip r a 192.168.1.2/32 dev vxlan0 tunnel dst 10.0.0.2
>   # ip r a 192.168.1.3/32 dev vxlan0 tunnel dst 10.0.0.3
>   # ip r
>   [...]
>   192.168.1.2/32 tunnel id 0 src 0.0.0.0 dst 10.0.0.2 [...]
>   192.168.1.3/32 tunnel id 0 src 0.0.0.0 dst 10.0.0.2 [...]
> 
> Implement the missing comparison function.
> 
> Fixes: 3093fbe7ff4bc ("route: Per route IP tunnel metadata via lightweight tunnel")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
