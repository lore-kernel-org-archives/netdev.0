From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: RE: [PATCH net-next 05/12] net: dsa: b53: Use a macro to define I/O operations
Date: Tue, 19 Sep 2017 10:19:35 -0400
Message-ID: <87tvzy93ew.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-6-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD007A003@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "davem\@davemloft.net" <davem@davemloft.net>,
        "andrew\@lunn.ch" <andrew@lunn.ch>
To: David Laight <David.Laight@ACULAB.COM>,
        'Florian Fainelli' <f.fainelli@gmail.com>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38894 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbdISOXK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:23:10 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD007A003@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Laight <David.Laight@ACULAB.COM> writes:

> From: Florian Fainelli
>> Sent: 18 September 2017 22:41
>> Instead of repeating the same pattern: acquire mutex, read/write, release
>> mutex, define a macro: b53_build_op() which takes the type (read|write), I/O
>> size, and value (scalar or pointer). This helps with fixing bugs that could
>> exit (e.g: missing barrier, lock etc.).
> ....
>> +#define b53_build_op(type, op_size, val_type)	\
>> +static inline int b53_##type##op_size(struct b53_device *dev, u8 page,		\
>> +				      u8 reg, val_type val)			\
>> +{										\
>> +	int ret;								\
>> +										\
>> +	mutex_lock(&dev->reg_mutex);						\
>> +	ret = dev->ops->type##op_size(dev, page, reg, val);			\
>> +	mutex_unlock(&dev->reg_mutex);						\
>> +										\
>> +	return ret;								\
>>  }
>
> Why separate the 'type' and 'op_size' arguments since they
> are always pasted together?

For read/write48, the value type is u64.


Thanks,

        Vivien
