From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Thu, 4 Apr 2013 18:08:34 +0200
Message-ID: <20130404160834.GC1688@minipsycho.brq.redhat.com>
References: <1364917500.5113.176.camel@edumazet-glaptop>
 <20130402155822.GB29115@redhat.com>
 <20130402.121223.496337697838525487.davem@davemloft.net>
 <1364920077.5113.185.camel@edumazet-glaptop>
 <20130404153530.GA1688@minipsycho.brq.redhat.com>
 <1365090287.3308.3.camel@edumazet-glaptop>
 <1365091425.3308.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vfalico@redhat.com,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:34360 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762575Ab3DDQIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:08:38 -0400
Received: by mail-we0-f175.google.com with SMTP id t11so2199464wey.34
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 09:08:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1365091425.3308.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 04, 2013 at 06:03:45PM CEST, eric.dumazet@gmail.com wrote:
>On Thu, 2013-04-04 at 08:44 -0700, Eric Dumazet wrote:
>
>> Because maybe the synchronize_net() in netdev_rx_handler_unregister()
>> is enough and you dont even need the call_rcu(). Thats was my question.
>
>So we have the following sequence in team_port_del()
>
>        netdev_rx_handler_unregister(port_dev);
>
>        netdev_upper_dev_unlink(port_dev, dev);
>        team_port_disable_netpoll(port);
>        vlan_vids_del_by_dev(port_dev, dev);
>        dev_uc_unsync(port_dev, dev);
>        dev_mc_unsync(port_dev, dev);
>        dev_close(port_dev);
>        team_port_leave(team, port);
>
>        __team_option_inst_mark_removed_port(team, port);
>        __team_options_change_check(team);
>        __team_option_inst_del_port(team, port);
>        __team_port_change_port_removed(port);
>
>        team_port_set_orig_dev_addr(port);
>        dev_set_mtu(port_dev, port->orig.mtu);
>        synchronize_rcu();
>        kfree(port);
>
>And I suspect we can remove synchronize_rcu() call.

I agree.

>
>But as this is a long list of operations, maybe some of them requires
>the rcu grace period before kfree(port)

None of them requires that.

>
>
>
