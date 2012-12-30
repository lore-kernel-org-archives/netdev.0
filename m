From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch net-next 01/15] net: introduce upper device lists
Date: Sun, 30 Dec 2012 10:00:42 -0800
Message-ID: <50E0814A.3090100@candelatech.com>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us> <1356868702-8144-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34215 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab2L3SCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 13:02:22 -0500
In-Reply-To: <1356868702-8144-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2012 03:58 AM, Jiri Pirko wrote:
> This lists are supposed to serve for storing pointers to all upper devices.
> Eventually it will replace dev->master pointer which is used for
> bonding, bridge, team but it cannot be used for vlan, macvlan where
> there might be multiple upper present. In case the upper link is
> replacement for dev->master, it is marked with "master" flag.

This is confusing and full of grammatical errors.  For instance, the 'it'
in "team but it cannot be used"...you are talking about the list this
patch introduces, or the old dev->master?

>
> New upper device list resolves this limitation. Also, the information
> stored in lists is used for preventing looping setups like
> "bond->somethingelse->samebond"
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/netdevice.h |  14 +++
>   net/core/dev.c            | 237 +++++++++++++++++++++++++++++++++++++++++++++-
>   2 files changed, 247 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 6835b58..52d1146 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1172,6 +1172,8 @@ struct net_device {
>   					  * which this device is member of.
>   					  */
>
> +	struct list_head	upper_dev_list; /* List of upper devices */
> +

Unless I mis-understand, this is often contains 'lower' devices instead,
and could contain a mixture.
Maybe this could use a rename, or at least a lot more comments?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
