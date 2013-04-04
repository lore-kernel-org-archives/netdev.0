From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] bridge: remove a redundant synchronize_net()
Date: Thu, 4 Apr 2013 18:07:06 +0200
Message-ID: <20130404160706.GB1688@minipsycho.brq.redhat.com>
References: <1364917500.5113.176.camel@edumazet-glaptop>
 <20130402155822.GB29115@redhat.com>
 <20130402.121223.496337697838525487.davem@davemloft.net>
 <1364920077.5113.185.camel@edumazet-glaptop>
 <20130404153530.GA1688@minipsycho.brq.redhat.com>
 <1365090287.3308.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vfalico@redhat.com,
	netdev@vger.kernel.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:63263 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759957Ab3DDQHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:07:10 -0400
Received: by mail-we0-f176.google.com with SMTP id s43so2097672wey.7
        for <netdev@vger.kernel.org>; Thu, 04 Apr 2013 09:07:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1365090287.3308.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 04, 2013 at 05:44:47PM CEST, eric.dumazet@gmail.com wrote:
>On Thu, 2013-04-04 at 17:35 +0200, Jiri Pirko wrote:
>
>> It can be converted now to call_rcu. synchronize_rcu is making sure
>> no packet is in flight when changing modes.
>
>What changes exactly ? You don't really answer to my question with this
>very vague sentence.

Sorry for vagueness. We discussed this in thread from Oct 2011:
Subject: [patch net-next V2] net: introduce ethernet teaming device

purpose of synchronize_rcu() here (instead of call_rcu) was to ensure that
rx_handler can not be in progress when __team_change_mode() changes
team->ops.receive to NULL

>
>Because maybe the synchronize_net() in netdev_rx_handler_unregister()
>is enough and you dont even need the call_rcu(). Thats was my question.

Yes, you are right. kfree(port) can be called right away.

>
>RCU barriers are not magical things we add when we are not exactly sure
>of what is happening.

I always thought that synchronize_rcu() is from the magic land of elfs and fairies...

>
>Like other barriers (wmb(), smb_wmb(), ...) we should document or
>understand why they are needed.
>
>
