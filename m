From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Fri, 24 Jul 2015 09:19:52 -0600
Message-ID: <55B25798.2040706@cumulusnetworks.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B24B9B.4080001@cumulusnetworks.com> <55B24C85.2010502@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch
To: nicolas.dichtel@6wind.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38367 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbGXPTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 11:19:55 -0400
Received: by iggf3 with SMTP id f3so19239625igg.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 08:19:55 -0700 (PDT)
In-Reply-To: <55B24C85.2010502@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/15 8:32 AM, Nicolas Dichtel wrote:
> Le 24/07/2015 16:28, David Ahern a =E9crit :
>> On 7/23/15 8:22 AM, Nicolas Dichtel wrote:
>>>   static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>>>                    struct net_device *dev)
>>>   {
>>> +    int nsid =3D skb_lwt_netns_info(skb);
>>>       struct pcpu_lstats *lb_stats;
>>>       int len;
>>>
>>> +    if (nsid >=3D 0) {
>>> +        struct net *peernet =3D get_net_ns_by_id(dev_net(dev), nsi=
d);
>>> +
>>> +        if (!peernet) {
>>
>> If nsid is > 0 then the peer namespace should exist right? So for th=
is
>> failure
>> path why not increment tx_error stat?
> I was not sure about that, because before my patch we increment
> statistics only
> in case of NET_RX_SUCCESS.

In this case you are knowingly dropping packets. Would be nice to have =
a=20
counter showing that.
