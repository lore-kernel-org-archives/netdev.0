From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: switchdev: Add
 switchdev_port_bridge_getlink_deferred
Date: Mon, 9 Jan 2017 12:29:28 -0800
Message-ID: <7994849c-5231-c0ee-e9e7-0c21c570f859@gmail.com>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109194503.10713-4-f.fainelli@gmail.com>
 <20170109201135.GE3771@localhost.localdomain>
 <78bba92c-aa8e-ee1e-4b7a-3625d6f6309a@gmail.com>
 <20170109202817.GF3771@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@resnulli.us
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34039 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754374AbdAIU3b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:29:31 -0500
Received: by mail-pf0-f193.google.com with SMTP id y143so4096633pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:29:30 -0800 (PST)
In-Reply-To: <20170109202817.GF3771@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2017 12:28 PM, Marcelo Ricardo Leitner wrote:
> On Mon, Jan 09, 2017 at 12:13:19PM -0800, Florian Fainelli wrote:
>> On 01/09/2017 12:11 PM, Marcelo Ricardo Leitner wrote:
>>> On Mon, Jan 09, 2017 at 11:45:02AM -0800, Florian Fainelli wrote:
>>>> Add switchdev_port_bridge_getlink_deferred() which does a deferred
>>>> object dump operation, this is required for e.g: DSA switches which
>>>> typically have sleeping I/O operations which is incompatible with being
>>>> in atomic context obviously.
>>>>
>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>> ---
>>
>>>>  	struct switchdev_attr attr = {
>>>>  		.orig_dev = dev,
>>>> @@ -829,12 +841,49 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>>>  	if (err && err != -EOPNOTSUPP)
>>>>  		return err;
>>>>  
>>>> -	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
>>>> +	return ndo_dflt_bridge_getlink(skb, pid, seq, d, mode,
>>>
>>> Was this s/dev/d/ by mistake?
>>
>> No, it's not a mistake, it was made so that the function signature could
>> be within 80 columns.
> 
> Right, but the change on the signature is on the chunk prior to this
> one. Yet this one is not on the prototype and leads to:
> 
> .../linux/net/switchdev/switchdev.c: In function ‘__switchdev_port_bridge_getlink’:
> .../linux/net/switchdev/switchdev.c:844:48: error: ‘d’ undeclared (first use in this function)
>   return ndo_dflt_bridge_getlink(skb, pid, seq, d, mode,
>                                                 ^
> .../linux/net/switchdev/switchdev.c:844:48: note: each undeclared identifier is reported only once for each function it appears in
> .../linux/net/switchdev/switchdev.c:847:1: warning: control reaches end of non-void function [-Wreturn-type]

That's embarrassing, looks like I changed it after the fact to please
checkpatch.pl, that's a mistake. Thanks!
-- 
Florian
