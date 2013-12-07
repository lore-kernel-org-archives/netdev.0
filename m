From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Sat, 7 Dec 2013 19:18:06 +0100
Message-ID: <20131207181806.GA2516@minipsycho.orion>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
 <20131206.154321.1673089712073824539.davem@davemloft.net>
 <20131206131028.41b5b8b1@nehalam.linuxnetplumber.net>
 <20131207085105.GA2496@minipsycho.orion>
 <20131207094235.2541c81f@samsung-9.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jtluka@redhat.com, zhiguohong@tencent.com,
	bridge@lists.linux-foundation.org, edumazet@google.com,
	laine@redhat.com, mst@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:60591 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab3LGSSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 13:18:10 -0500
Received: by mail-ee0-f50.google.com with SMTP id c41so822469eek.23
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 10:18:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131207094235.2541c81f@samsung-9.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Dec 07, 2013 at 06:42:35PM CET, stephen@networkplumber.org wrote:
>On Sat, 7 Dec 2013 09:51:05 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> Fri, Dec 06, 2013 at 10:10:28PM CET, stephen@networkplumber.org wrote:
>> >On Fri, 06 Dec 2013 15:43:21 -0500 (EST)
>> >David Miller <davem@davemloft.net> wrote:
>> >
>> >> From: Jiri Pirko <jiri@resnulli.us>
>> >> Date: Thu,  5 Dec 2013 16:27:37 +0100
>> >> 
>> >> > br_stp_rcv() is reached by non-rx_handler path. That means there is no
>> >> > guarantee that dev is bridge port and therefore simple NULL check of
>> >> > ->rx_handler_data is not enough. There is need to check if dev is really
>> >> > bridge port and since only rcu read lock is held here, do it by checking
>> >> > ->rx_handler pointer.
>> >> > 
>> >> > Note that synchronize_net() in netdev_rx_handler_unregister() ensures
>> >> > this approach as valid.
>> >> > 
>> >> > Introduced originally by:
>> >> > commit f350a0a87374418635689471606454abc7beaa3a
>> >> >   "bridge: use rx_handler_data pointer to store net_bridge_port pointer"
>> >> > 
>> >> > Fixed but not in the best way by:
>> >> > commit b5ed54e94d324f17c97852296d61a143f01b227a
>> >> >   "bridge: fix RCU races with bridge port"
>> >> > 
>> >> > Reintroduced by:
>> >> > commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
>> >> >   "bridge: fix NULL pointer deref of br_port_get_rcu"
>> >> > 
>> >> > Please apply to stable trees as well. Thanks.
>> >> > 
>> >> > RH bugzilla reference: https://bugzilla.redhat.com/show_bug.cgi?id=1025770
>> >> > 
>> >> > Reported-by: Laine Stump <laine@redhat.com>
>> >> > Debugged-by: Michael S. Tsirkin <mst@redhat.com>
>> >> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> >> > Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> >> > ---
>> >> > v1->v2: moved br_port_get_check_rcu definition below br_handle_frame definition
>> >> 
>> >> Applied and queued up for -stable, thanks Jiri.
>> >
>> >How come you ignored my simpler fix, that used the existing logic.
>> >I don't like introducing this especially into the stable; much prefer
>> >to go back to testing the flag as was being done before.
>> 
>> Although your patch is technically sane, it depends on rtnl indirectly.
>> My patch depends on rcu locking and synchronize_rcu which is direct.
>> Therefore I think it is more appropriate.
>
>After more review and thought I agree. But could we put some comments
>in br_private.h to describe the dependency on ordering (synchronize_net).

Sure. I will send follow-up patch addressing it. Thanks.

>
>Acked-by: Stephen Hemminger <stephen@networkplumber.org>
