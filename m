From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 1/2] openvswitch: Use regular GRE net_device
 instead of vport
Date: Mon, 3 Aug 2015 22:55:25 -0700
Message-ID: <CALnjE+ooDLxTryGXhqt03UHhOyk+OfEcbAqECdGS+JotXJ5mrA@mail.gmail.com>
References: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
	<20150804042339.GA47032@Alexeis-MBP.westell.com>
	<20150803.215955.1031623872655808616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38531 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbHDFz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 01:55:27 -0400
Received: by iggf3 with SMTP id f3so4634252igg.1
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 22:55:25 -0700 (PDT)
In-Reply-To: <20150803.215955.1031623872655808616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 3, 2015 at 9:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Date: Mon, 3 Aug 2015 21:23:40 -0700
>
>> On Mon, Aug 03, 2015 at 05:27:26PM -0700, Pravin B Shelar wrote:
>>> With addition of flow based tunneling, there is no need to
>>> have special GRE vport. Removes all of the OVS specific
>>> GRE code and make OVS use a ip_gre net_device.
>>> Minimal GRE vport is kept to handle compatibility with
>>> current userspace application.
>>>
>>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> ...
>>> +#define GRE_TAP_FB_NAME "gretap0"
>> ...
>>> +    /* fallback device is used for flow based tunneling. */
>>> +    if (!strcmp(dev->name, GRE_TAP_FB_NAME)) {
>>> +            struct ip_tunnel *t;
>>> +
>>> +            t = netdev_priv(dev);
>>> +            t->flow_based_tunnel = true;
>>> +            eth_hw_addr_random(dev);
>>> +            netif_keep_dst(dev);
>>> +    }
>>> +
>>
>> feature detection based on netdev name?
>> meaning that there will be only one such device for the whole
>> host? and namespaces cannot have their own gre tunnels?
>> (since host 'gretap0' cannot be seen in netns)
>
> Doing anything like this by netdev name is wrong.
>
> Pravin you will need to do this in some other way.
>
ok, I will add API to create flow-based GRE device.
