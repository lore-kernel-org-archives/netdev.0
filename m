From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 07/13] dsa: implement ndo_swdev_get_id
Date: Fri, 5 Sep 2014 07:52:34 +0200
Message-ID: <20140905055234.GA1923@nanopsycho.lan>
References: <1409736300-12303-1-git-send-email-jiri@resnulli.us>
 <1409736300-12303-8-git-send-email-jiri@resnulli.us>
 <5407A25A.8050401@gmail.com>
 <20140904124701.GH1867@nanopsycho.lan>
 <54093F6B.7080507@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	dev@openvswitch.org, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:33656 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaIEFwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:52:39 -0400
Received: by mail-lb0-f175.google.com with SMTP id u10so12630608lbd.20
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 22:52:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <54093F6B.7080507@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 05, 2014 at 06:43:23AM CEST, nbd@openwrt.org wrote:
>On 2014-09-04 14:47, Jiri Pirko wrote:
>> Thu, Sep 04, 2014 at 01:20:58AM CEST, f.fainelli@gmail.com wrote:
>>>On 09/03/2014 02:24 AM, Jiri Pirko wrote:
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>> ---
>>>>  include/linux/netdevice.h |  3 ++-
>>>>  include/net/dsa.h         |  1 +
>>>>  net/dsa/Kconfig           |  2 +-
>>>>  net/dsa/dsa.c             |  3 +++
>>>>  net/dsa/slave.c           | 10 ++++++++++
>>>>  5 files changed, 17 insertions(+), 2 deletions(-)
>>>> 
>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>> index 6a009d1..7ee070f 100644
>>>> --- a/include/linux/netdevice.h
>>>> +++ b/include/linux/netdevice.h
>>>> @@ -41,7 +41,6 @@
>>>>  
>>>>  #include <linux/ethtool.h>
>>>>  #include <net/net_namespace.h>
>>>> -#include <net/dsa.h>
>>>>  #ifdef CONFIG_DCB
>>>>  #include <net/dcbnl.h>
>>>>  #endif
>>>> @@ -1259,6 +1258,8 @@ enum netdev_priv_flags {
>>>>  #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
>>>>  #define IFF_MACVLAN			IFF_MACVLAN
>>>>  
>>>> +#include <net/dsa.h>
>>>> +
>>>>  /**
>>>>   *	struct net_device - The DEVICE structure.
>>>>   *		Actually, this whole structure is a big mistake.  It mixes I/O
>>>> diff --git a/include/net/dsa.h b/include/net/dsa.h
>>>> index 9771292..d60cd42 100644
>>>> --- a/include/net/dsa.h
>>>> +++ b/include/net/dsa.h
>>>> @@ -140,6 +140,7 @@ struct dsa_switch {
>>>>  	u32			phys_mii_mask;
>>>>  	struct mii_bus		*slave_mii_bus;
>>>>  	struct net_device	*ports[DSA_MAX_PORTS];
>>>> +	struct netdev_phys_item_id psid;
>>>>  };
>>>>  
>>>>  static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
>>>> diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
>>>> index a585fd6..4e144a2 100644
>>>> --- a/net/dsa/Kconfig
>>>> +++ b/net/dsa/Kconfig
>>>> @@ -1,6 +1,6 @@
>>>>  config HAVE_NET_DSA
>>>>  	def_bool y
>>>> -	depends on NETDEVICES && !S390
>>>> +	depends on NETDEVICES && NET_SWITCHDEV && !S390
>>>
>>>It does not look like this is necessary, we are only using definitions
>>>from net/dsa.h and include/linux/netdevice.h, and if it was, a 'select'
>>>would be more appropriate here I think.
>>>
>>>TBH, I think we should rather drop this patch for now, I do not see any
>>>benefit in providing a random id over no-id at all.
>> 
>> Well, the benefit is that you are still able to see which ports belong
>> to the same switch.
>I think it's a bad idea to force switchdev bloat onto DSA users just for
>that random id thing.

Np. I will drop this.

>
>- Felix
