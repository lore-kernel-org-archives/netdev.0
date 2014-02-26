From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 01/14] brcmfmac: add delay before unregistering the network
 device
Date: Wed, 26 Feb 2014 13:18:25 +0100
Message-ID: <530DDB91.3070807@broadcom.com>
References: <1393356639-19169-1-git-send-email-arend@broadcom.com>					 <1393356639-19169-2-git-send-email-arend@broadcom.com>					 (sfid-20140225_203048_842452_A39499B6) <1393358376.4170.22.camel@jlt4.sipsolutions.net>				 <530DAECD.8010405@broadcom.com>			 <1393406278.4133.4.camel@jlt4.sipsolutions.net>			 <530DB3BA.20106@broadcom.com>		 <1393407473.4133.5.camel@jlt4.sipsolutions.net>		 <530DC56E.9040202@broadcom.com>	 <1393413044.4133.6.camel@jlt4.sipsolutions.net>	 <530DD131.50205@broadcom.com> <1393415288.4133.7.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:41328 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaBZMS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 07:18:29 -0500
In-Reply-To: <1393415288.4133.7.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2014 12:48 PM, Johannes Berg wrote:
> On Wed, 2014-02-26 at 12:34 +0100, Arend van Spriel wrote:
> 
>>> I'm not sure this isn't still possible? I don't know when DELLINK is
>>> sent.
>>
>> Given the behaviour I would say before the netdev notifier, which may be
>> considered wrong. It depends whether the notifier was intended for the
>> kind of thing that cfg80211 is doing, ie. send a netlink event to
>> user-space?
> 
> Well, I checked:
> 
>                 call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> 
>                 if (!dev->rtnl_link_ops ||
>                     dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
>                         rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
> 
> so ... :)

Feeling sad :-( but thanks for checking. Clearly need to look into this
some more. John, can you please drop this one.

Gr. AvS
