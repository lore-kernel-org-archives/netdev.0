From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 23:35:31 +0200
Message-ID: <1349213731.12401.1141.camel@edumazet-glaptop>
References: <1349121884.12401.721.camel@edumazet-glaptop>
	 <1349192133.12401.768.camel@edumazet-glaptop>
	 <1349192919.12401.778.camel@edumazet-glaptop>
	 <20121002.142502.1702895723099297167.davem@davemloft.net>
	 <506B5918.605@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de, davej@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61787 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab2JBVfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 17:35:36 -0400
Received: by bkcjk13 with SMTP id jk13so5765740bkc.19
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 14:35:34 -0700 (PDT)
In-Reply-To: <506B5918.605@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-02 at 14:14 -0700, Alexander Duyck wrote:

> I think something may have been missed in this patch.
> 
> With it applied to net-next I am unable to remove the ixgbe driver after
> running a routing traffic test.  The specific message I am getting is:
>     unregister_netdevice: waiting for eth2 to become free. Usage count = -7

Yes, I realized later that rt_set_nexthop(), called from
__mkroute_input() was responsible to do the caching...

So another version is needed, I'll do that tomorrow unless David can fix
the problem while I sleep a bit ;)
