From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from userspace
Date: Wed, 12 Dec 2012 19:25:56 +0100
Message-ID: <20121212182556.GC3060@minipsycho.orion>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
 <20121212081500.24085752@nehalam.linuxnetplumber.net>
 <20121212170520.GA3060@minipsycho.orion>
 <20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
 <20121212181017.GB3060@minipsycho.orion>
 <20121212101208.361ccda0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:64910 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754900Ab2LLS0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 13:26:00 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so345102eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 10:25:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121212101208.361ccda0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 12, 2012 at 07:12:08PM CET, shemminger@vyatta.com wrote:
>On Wed, 12 Dec 2012 19:10:17 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> ># ip li show dev dummy0
>> >12: dummy0: <NO-CARRIER,BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state DORMANT mode DORMANT   
>> 
>> if you mean this "NO-CARRIER"
>> it has no direct relation with netif_carrier_ok().
>
>It is the same value (IFF_RUNNING) that is visible from user space.

static inline bool netif_carrier_ok(const struct net_device *dev)
{
	        return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
}

So netif_carrier[ok/on/off] are working with on __LINK_STATE_NOCARRIER
bit. Not with IFF_RUNNING flag.
