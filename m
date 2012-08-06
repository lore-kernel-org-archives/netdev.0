From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 5/5] net: Loopback ifindex is constant now
Date: Mon, 06 Aug 2012 16:13:35 +0400
Message-ID: <501FB4EF.6060403@parallels.com>
References: <501F9CAF.3030605@parallels.com>  <501F9D2B.8000504@parallels.com> <1344254071.26674.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17325 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756055Ab2HFMNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 08:13:43 -0400
In-Reply-To: <1344254071.26674.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2012 03:54 PM, Eric Dumazet wrote:
> On Mon, 2012-08-06 at 14:32 +0400, Pavel Emelyanov wrote:
>> As pointed out, there are places, that access net->loopback_dev->ifindex
>> and after ifindex generation is made per-net this value becomes constant
>> equals 1. So go ahead and introduce the LOOPBACK_IFINDEX constant and use
>> it where appropriate.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
> 
> What guarantee do we have that loopback is the first device per net ?

In net_dev_init():

        /* The loopback device is special if any other network devices
         * is present in a network namespace the loopback device must
         * be present. Since we now dynamically allocate and free the
         * loopback device ensure this invariant is maintained by
         * keeping the loopback device as the first device on the
         * list of network devices.  Ensuring the loopback devices
         * is the first device that appears and the last network device
         * that disappears.
         */
        if (register_pernet_device(&loopback_net_ops))
                goto out;


> You should add this to the changelog because its not that obvious.

OK.

Thanks,
Pavel
