From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Tue, 02 Apr 2013 09:27:57 -0700
Message-ID: <1364920077.5113.185.camel@edumazet-glaptop>
References: <1364917500.5113.176.camel@edumazet-glaptop>
	 <20130402155822.GB29115@redhat.com>
	 <20130402.121223.496337697838525487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, Jiri Pirko <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:64087 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761707Ab3DBQ2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 12:28:00 -0400
Received: by mail-pb0-f54.google.com with SMTP id xa7so336122pbc.13
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 09:28:00 -0700 (PDT)
In-Reply-To: <20130402.121223.496337697838525487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-02 at 12:12 -0400, David Miller wrote:

> Note that we have a few spots now that do two synchronize_net()'s per
> opertaion, such as team port removal, and openvswitch has such a path
> as well.  They all are of the form:
> 
> 	netdev_rx_handler_unregister()
> 	...
> 	lots of other stuff
> 	...
> 	synchronize_net();
> 
> So might be harder to factor back out than this br_if.c case.
> 

Strange, I do see call_rcu() in openvswitch, not a synchronize_{net|
rcu}(). Probably OK to leave as is, as it's not a big deal.

I'll let Jiri handle the team driver change, as its not clear what
synchronize_rcu() call in team_port_del() is protecting
