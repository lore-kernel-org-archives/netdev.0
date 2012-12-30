From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Sun, 30 Dec 2012 23:08:50 +0100
Message-ID: <20121230220850.GE1575@minipsycho.orion>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us>
 <1356868702-8144-2-git-send-email-jiri@resnulli.us>
 <50E0814A.3090100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f177.google.com ([209.85.215.177]:51888 "EHLO
	mail-ea0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab2L3WIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 17:08:55 -0500
Received: by mail-ea0-f177.google.com with SMTP id c10so4910319eaa.22
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 14:08:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50E0814A.3090100@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 30, 2012 at 07:00:42PM CET, greearb@candelatech.com wrote:
>On 12/30/2012 03:58 AM, Jiri Pirko wrote:
>>This lists are supposed to serve for storing pointers to all upper devices.
>>Eventually it will replace dev->master pointer which is used for
>>bonding, bridge, team but it cannot be used for vlan, macvlan where
>>there might be multiple upper present. In case the upper link is
>>replacement for dev->master, it is marked with "master" flag.
>
>This is confusing and full of grammatical errors.  For instance, the 'it'
>in "team but it cannot be used"...you are talking about the list this
>patch introduces, or the old dev->master?

Sorry for my grammar, it stinks...

dev->master cannot be used for for vlan, macvlan. More upper devices
might be present for this type of devices and dev->master would not cover it.

So, In case there is only *one* upper device, "master" flag is used.

I Hope I cleared this one for you.


>
>>
>>New upper device list resolves this limitation. Also, the information
>>stored in lists is used for preventing looping setups like
>>"bond->somethingelse->samebond"
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  include/linux/netdevice.h |  14 +++
>>  net/core/dev.c            | 237 +++++++++++++++++++++++++++++++++++++++++++++-
>>  2 files changed, 247 insertions(+), 4 deletions(-)
>>
>>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>index 6835b58..52d1146 100644
>>--- a/include/linux/netdevice.h
>>+++ b/include/linux/netdevice.h
>>@@ -1172,6 +1172,8 @@ struct net_device {
>>  					  * which this device is member of.
>>  					  */
>>
>>+	struct list_head	upper_dev_list; /* List of upper devices */
>>+
>
>Unless I mis-understand, this is often contains 'lower' devices instead,
>and could contain a mixture.
>Maybe this could use a rename, or at least a lot more comments?

I'm terribly sorry, but I believe this is the case when I do not
understand your grammar. For example "this is often contains 'lower'
devices instead".

But in any case, no, list of upper devices contains only "upper" devices.
Meaning the set of devices which are using the original one as "lower".
Never the other way.

And to reply to your comment to patch "[patch net-next 04/15] rtnetlink:
remove usage of dev->master" as well:

upper dev is the device that is somehow using the lower dev for its
work. For bonding, you may call that lower device "slave", for bridge,
"port". And macvlan is also linked to it's lower device, the one on what
it is hooked on by rx_handler.


I hope this clears this for you a bit.

Thanks

Jiri.

>
>Thanks,
>Ben
>
>-- 
>Ben Greear <greearb@candelatech.com>
>Candela Technologies Inc  http://www.candelatech.com
>
>
