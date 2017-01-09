From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: switchdev: Add
 switchdev_port_bridge_getlink_deferred
Date: Mon, 9 Jan 2017 12:13:19 -0800
Message-ID: <78bba92c-aa8e-ee1e-4b7a-3625d6f6309a@gmail.com>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109194503.10713-4-f.fainelli@gmail.com>
 <20170109201135.GE3771@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        jiri@resnulli.us
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34207 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbdAIUNV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:13:21 -0500
Received: by mail-pf0-f195.google.com with SMTP id y143so4052760pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:13:21 -0800 (PST)
In-Reply-To: <20170109201135.GE3771@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2017 12:11 PM, Marcelo Ricardo Leitner wrote:
> On Mon, Jan 09, 2017 at 11:45:02AM -0800, Florian Fainelli wrote:
>> Add switchdev_port_bridge_getlink_deferred() which does a deferred
>> object dump operation, this is required for e.g: DSA switches which
>> typically have sleeping I/O operations which is incompatible with being
>> in atomic context obviously.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---

>>  	struct switchdev_attr attr = {
>>  		.orig_dev = dev,
>> @@ -829,12 +841,49 @@ int switchdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>>  	if (err && err != -EOPNOTSUPP)
>>  		return err;
>>  
>> -	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
>> +	return ndo_dflt_bridge_getlink(skb, pid, seq, d, mode,
> 
> Was this s/dev/d/ by mistake?

No, it's not a mistake, it was made so that the function signature could
be within 80 columns.
-- 
Florian
