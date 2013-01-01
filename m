From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Tue, 1 Jan 2013 02:04:01 +0100
Message-ID: <20130101010401.GA1515@minipsycho.orion>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
 <1356868702-8144-2-git-send-email-jiri@resnulli.us>
 <20121231112212.03319226@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com, fbl@redhat.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, ebiederm@xmission.com, joe@perches.com,
	amwang@redhat.com, nhorman@tuxdriver.com,
	john.r.fastabend@intel.com, pablo@netfilter.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:45170 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab3AABEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 20:04:09 -0500
Received: by mail-ee0-f48.google.com with SMTP id b57so6528078eek.21
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2012 17:04:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121231112212.03319226@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 31, 2012 at 08:22:12PM CET, shemminger@vyatta.com wrote:
>On Sun, 30 Dec 2012 12:58:08 +0100
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> This lists are supposed to serve for storing pointers to all upper devices.
>> Eventually it will replace dev->master pointer which is used for
>> bonding, bridge, team but it cannot be used for vlan, macvlan where
>> there might be multiple upper present. In case the upper link is
>> replacement for dev->master, it is marked with "master" flag.
>> 
>> New upper device list resolves this limitation. Also, the information
>> stored in lists is used for preventing looping setups like
>> "bond->somethingelse->samebond"
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>I like the concept of knowing the topology of layered network devices.
>The name "upper device lists" is a little confusing to me.

Well, it's a list of devices "upper" to this one. Please provide more
suitable name alternative. I can't think of any, in fact I think "upper"
is pretty suitable.


>Also, the amount of additional data structures and book keeping
>seems more than needed; but not sure how to reduce it down to the
>least code.

Yep, that's it. I tried to make that as slim as possible. Trimming ideas
are very welcome.

>
>For simple case of detecting loops, just using existing master
>pointer is sufficient.
>       ethernet --> bonding --> bridge --+
>                       ^                 |
>                       |                 |
>                       +-----------------+
>This is the simple case of detecting if singularly linked list
>is a loop.
>
>The only device where multiple upper devices is possible seems
>to be macvlan. Could the special case code be limited to there?

Well, there are others, vlan for example. And the whole concept is to
make this uniform and generic, to avoid specific code for specific
drivers. And there are some usecases which can benefit from the upper
lists, like for example drivers which need to obtain l3 address info
(cxgb3, qlcnic, qeth).

But in any case, I doubt that this alternative approach will
lead to much smaller code footprint. I think it would be just more
messy.
