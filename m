From: Pavel Emelianov <xemul@openvz.org>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Mon, 16 Jul 2007 13:16:57 +0400
Message-ID: <469B3789.8030303@openvz.org>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <469631F5.7080207@trash.net> <46963457.1000306@openvz.org> <46963673.3010506@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:41063 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbXGPJRH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 05:17:07 -0400
In-Reply-To: <46963673.3010506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> Patrick McHardy wrote:
>>
>>> Pavel Emelianov wrote:
>>>
>>>> +	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
>>>> +		err = nla_parse_nested(tb, IFLA_INFO_MAX,
>>>> +				data[VETH_INFO_PEER], ifla_policy);
>>>> +		if (err < 0)
>>>> +			return err;
>>>> +	}
>>>
>>> One more suggestion regarding the PEER attribute: you only nest
>>> IFLA attributes below it, but some information that might be
>>> interesting to use on device creation is contained in ifinfomsg
>>> (flags and ifindex). So I think it would be better to use a
>>> complete message, including header.
>>
>> I don't get it. Can you elaborate, please.
> 
> 
> You don't have a struct ifinfomsg for the peer device. At some
> point we might want to add support for specifying initial flags
> for the device (some easily supportable ones are IFF_PROMISC,
> IFF_ALLMULTI, IFF_NOARP) and ideally that should also be possible
> for the peer device.
> 
> So I suggest you use a complete ifinfomsg including the header
> instead of just the attributes for VETH_INFO_PEER.
> 
> 

I don't see any information from this struct being used on the
link-creation paths...

Pavel
