From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bonding-devel] [net-next-2.6 PATCH 2/3] bonding: check return
 value of nofitier when changing type
Date: Thu, 11 Mar 2010 08:59:09 +0100
Message-ID: <20100311075908.GA2785@psychotron.redhat.com>
References: <20100310202804.GC2834@psychotron.redhat.com>
 <20100310202935.GE2834@psychotron.redhat.com>
 <20100310144710.605ef033@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, davem@davemloft.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753705Ab0CKH7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 02:59:30 -0500
Content-Disposition: inline
In-Reply-To: <20100310144710.605ef033@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 10, 2010 at 11:47:10PM CET, shemminger@linux-foundation.org wrote:
>On Wed, 10 Mar 2010 21:29:35 +0100
>Jiri Pirko <jpirko@redhat.com> wrote:
>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index bcc490c..5de4a15 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1084,9 +1084,9 @@ void netdev_state_change(struct net_device *dev)
>>  }
>>  EXPORT_SYMBOL(netdev_state_change);
>>  
>> -void netdev_bonding_change(struct net_device *dev, unsigned long event)
>> +int netdev_bonding_change(struct net_device *dev, unsigned long event)
>>  {
>> -	call_netdevice_notifiers(event, dev);
>> +	return call_netdevice_notifiers(event, dev);
>>  }
>>  EXPORT_SYMBOL(netdev_bonding_change);
>>  
>
>I don't think all this pre-post stuff needed.
>Since this is general (not just bonding) how about

Well actually I reused NETDEV_BONDING_OLDTYPE. This and NETDEV_BONDING_NEWTYPE
is used in inetdev_event() and addrconf_notify(). These functions apparently
need to be notified before and after the change.

>
>int netdev_change_type(struct net_device *dev, int newtype)
>{
>	int ret, oldtype;
>
>	if (dev->flags & IFF_UP)
>		return -EBUSY;
>
>	oldtype = dev->type;
>	dev->type = newtype;
>	ret = call_netdevice_notifier(NETDEV_CHANGETYPE, dev);
>	ret = notifier_to_errno(ret);
>	if (ret)
>	     dev->type = oldtype;
>
>	return ret;
>}

I see you point here, but that would be another notifier event. Do you suggest
to have 3 of them finally? NETDEV_BONDING_OLDTYPE, NETDEV_BONDING_NEWTYPE and
NETDEV_CHANGETYPE. Looks a bit redundant to me...

Thanks.

Jirka

