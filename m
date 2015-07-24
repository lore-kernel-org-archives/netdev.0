From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Fri, 24 Jul 2015 16:32:37 +0200
Message-ID: <55B24C85.2010502@6wind.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B24B9B.4080001@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch
To: David Ahern <dsa@cumulusnetworks.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36710 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbbGXOcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 10:32:39 -0400
Received: by wicgb10 with SMTP id gb10so31553547wic.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 07:32:38 -0700 (PDT)
In-Reply-To: <55B24B9B.4080001@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/07/2015 16:28, David Ahern a =E9crit :
> On 7/23/15 8:22 AM, Nicolas Dichtel wrote:
>>   static netdev_tx_t loopback_xmit(struct sk_buff *skb,
>>                    struct net_device *dev)
>>   {
>> +    int nsid =3D skb_lwt_netns_info(skb);
>>       struct pcpu_lstats *lb_stats;
>>       int len;
>>
>> +    if (nsid >=3D 0) {
>> +        struct net *peernet =3D get_net_ns_by_id(dev_net(dev), nsid=
);
>> +
>> +        if (!peernet) {
>
> If nsid is > 0 then the peer namespace should exist right? So for thi=
s failure
> path why not increment tx_error stat?
I was not sure about that, because before my patch we increment statist=
ics only
in case of NET_RX_SUCCESS.
