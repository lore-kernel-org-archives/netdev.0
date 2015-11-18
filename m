From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net: fix feature changes on devices without
 ndo_set_features
Date: Wed, 18 Nov 2015 13:51:48 +0300
Message-ID: <564C5844.9090109@cogentembedded.com>
References: <5645C0A5.2080506@cumulusnetworks.com>
 <1447422841-2333-1-git-send-email-razor@blackwall.org>
 <564BB22C.2000606@cogentembedded.com> <564BB3CF.2080507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jarod Wilson <jarod@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:34122 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbbKRKvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 05:51:53 -0500
Received: by lbbcs9 with SMTP id cs9so22006713lbb.1
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 02:51:51 -0800 (PST)
In-Reply-To: <564BB3CF.2080507@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/18/2015 2:10 AM, Nikolay Aleksandrov wrote:

>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>
>>> When __netdev_update_features() was updated to ensure some features are
>>> disabled on new lower devices, an error was introduced for devices which
>>> don't have the ndo_set_features() method set. Before we'll just set the
>>> new features, but now we return an error and don't set them. Fix this by
>>> returning the old behaviour and setting err to 0 when ndo_set_features
>>> is not present.
>>>
>>> Fixes: e7868a85e1b2 ("net/core: ensure features get disabled on new lower devs")
>>> CC: Jarod Wilson <jarod@redhat.com>
>>> CC: Jiri Pirko <jiri@resnulli.us>
>>> CC: Ido Schimmel <idosch@mellanox.com>
>>> CC: Sander Eikelenboom <linux@eikelenboom.it>
>>> CC: Andy Gospodarek <gospo@cumulusnetworks.com>
>>> CC: Florian Fainelli <f.fainelli@gmail.com>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> ---
>>> Sander please feel free to give your Tested-by.
>>>
>>>    net/core/dev.c | 2 ++
>>>    1 file changed, 2 insertions(+)
>>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index ab9b8d0d115e..4a1d198dbbff 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -6426,6 +6426,8 @@ int __netdev_update_features(struct net_device *dev)
>>>
>>>        if (dev->netdev_ops->ndo_set_features)
>>>            err = dev->netdev_ops->ndo_set_features(dev, features);
>>> +    else
>>> +        err = 0;
>>
>>     This makes the 'err' initializer pointless.
>
> It doesn't, there's a previous goto statement that might get hit and we
> need it to be -1 so we don't signal a feature change.

    Ah, sorry, it was late and I was being stupid. :-<

MBR, Sergei
