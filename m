From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Thu, 4 Apr 2013 17:35:30 +0200
Message-ID: <20130404153530.GA1688@minipsycho.brq.redhat.com>
References: <1364917500.5113.176.camel@edumazet-glaptop>
 <20130402155822.GB29115@redhat.com>
 <20130402.121223.496337697838525487.davem@davemloft.net>
 <1364920077.5113.185.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vfalico@redhat.com,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:61186 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759770Ab3DDPff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 11:35:35 -0400
Received: by mail-wi0-f180.google.com with SMTP id c10so2739654wiw.13
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 08:35:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1364920077.5113.185.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Apr 02, 2013 at 06:27:57PM CEST, eric.dumazet@gmail.com wrote:
>On Tue, 2013-04-02 at 12:12 -0400, David Miller wrote:
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
>Strange, I do see call_rcu() in openvswitch, not a synchronize_{net|
>rcu}(). Probably OK to leave as is, as it's not a big deal.
>
>I'll let Jiri handle the team driver change, as its not clear what
>synchronize_rcu() call in team_port_del() is protecting

It can be converted now to call_rcu. synchronize_rcu is making sure
no packet is in flight when changing modes.

>
>
>
