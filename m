From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Thu, 28 Mar 2013 18:10:48 -0700
Message-ID: <1364519448.15753.63.camel@edumazet-glaptop>
References: <20130328150410.GA22789@sergelap>
	 <CD7A1D9A.78BA%blourdel@juniper.net>
	 <20130328152040.2c905ad9@nehalam.linuxnetplumber.net>
	 <87zjxn84ks.fsf@xmission.com> <1364516016.15753.59.camel@edumazet-glaptop>
	 <87ppyj6ohh.fsf@xmission.com> <1364517837.15753.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	Serge Hallyn <serge.hallyn@ubuntu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:65163 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753392Ab3C2BKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 21:10:52 -0400
Received: by mail-pb0-f48.google.com with SMTP id wy12so49337pbc.21
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 18:10:52 -0700 (PDT)
In-Reply-To: <1364517837.15753.61.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-28 at 17:43 -0700, Eric Dumazet wrote:

> In batch mode, I can create these veth pairs in 4 seconds
> 
> for i in $(seq 1 5000) ; do echo link add a$i type veth peer name b$i;
> done | ip -batch -


At rmmod time, 30% of cpu is spent in packet_notifier()

Maybe we can do something about this.

   30.85%         rmmod  [kernel.kallsyms]     [k]
packet_notifier                                                                                 
                   |
                   --- packet_notifier
                       notifier_call_chain
                       raw_notifier_call_chain
                       call_netdevice_notifiers
                       rollback_registered_many
                       unregister_netdevice_many
                       __rtnl_link_unregister
                       rtnl_link_unregister
                       0xffffffffa0044868
                       sys_delete_module
                       sysenter_dispatch
