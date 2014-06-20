From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next] veth: add netpoll support
Date: Sat, 21 Jun 2014 00:15:46 +0400
Message-ID: <53A49672.1060601@cogentembedded.com>
References: <1403291878-4199-1-git-send-email-xiyou.wangcong@gmail.com> <53A48C12.8020104@cogentembedded.com> <20140620200758.GB18996@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	s.priebe@profihost.ag, "David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:46313 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755045AbaFTUPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 16:15:37 -0400
Received: by mail-lb0-f174.google.com with SMTP id u10so2630952lbd.5
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 13:15:36 -0700 (PDT)
In-Reply-To: <20140620200758.GB18996@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/21/2014 12:07 AM, Neil Horman wrote:

>>> It is trivial to add netpoll support to veth, since
>>> it is not stacked device, we don't need to setup and cleanup
>>> netpoll.

>>> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
>>> Cc: "David S. Miller" <davem@davemloft.net>
>>> Cc: Neil Horman <nhorman@tuxdriver.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

>>> ---
>>> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>>> index b4a10bc..03e781b 100644
>>> --- a/drivers/net/veth.c
>>> +++ b/drivers/net/veth.c
>>> @@ -248,6 +248,13 @@ static void veth_dev_free(struct net_device *dev)
>>>   	free_netdev(dev);
>>>   }
>>>
>>> +#ifdef CONFIG_NET_POLL_CONTROLLER
>>> +static void veth_poll_controller(struct net_device *dev)
>>> +{
>>> +	return;
>>
>>     Not needed.

> It is, a valid function poniter is how the stack determines if a given driver
> supports netpoll. See the tun_poll_controller for another example
> Neil

    I just said that *return* was not needed. :-)

>>
>>> +}
>>> +#endif	/* CONFIG_NET_POLL_CONTROLLER */
>>> +
>>>   static const struct net_device_ops veth_netdev_ops = {
>>>   	.ndo_init            = veth_dev_init,
>>>   	.ndo_open            = veth_open,

WBR, Sergei
