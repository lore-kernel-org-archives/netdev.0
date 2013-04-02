From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Tue, 02 Apr 2013 14:19:11 -0400 (EDT)
Message-ID: <20130402.141911.1660321473957546020.davem@davemloft.net>
References: <20130402155822.GB29115@redhat.com>
	<20130402.121223.496337697838525487.davem@davemloft.net>
	<1364920077.5113.185.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vfalico@redhat.com, netdev@vger.kernel.org,
	stephen@networkplumber.org, jiri@resnulli.us
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760298Ab3DBSTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:19:15 -0400
In-Reply-To: <1364920077.5113.185.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Apr 2013 09:27:57 -0700

> On Tue, 2013-04-02 at 12:12 -0400, David Miller wrote:
> 
>> Note that we have a few spots now that do two synchronize_net()'s per
>> opertaion, such as team port removal, and openvswitch has such a path
>> as well.  They all are of the form:
>> 
>> 	netdev_rx_handler_unregister()
>> 	...
>> 	lots of other stuff
>> 	...
>> 	synchronize_net();
>> 
>> So might be harder to factor back out than this br_if.c case.
>> 
> 
> Strange, I do see call_rcu() in openvswitch, not a synchronize_{net|
> rcu}(). Probably OK to leave as is, as it's not a big deal.

My bad, I misread the code.

> I'll let Jiri handle the team driver change, as its not clear what
> synchronize_rcu() call in team_port_del() is protecting

Ok.
