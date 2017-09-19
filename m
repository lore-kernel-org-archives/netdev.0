From: Florian Fainelli <f.fainelli@gmail.com>
Subject: RE: [PATCH net-next 05/12] net: dsa: b53: Use a macro to define I/O operations
Date: Tue, 19 Sep 2017 07:29:38 -0700
Message-ID: <12153E6A-CB96-4EED-91CE-05604B640927@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com> <20170918214128.27896-6-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6DD007A003@AcuExch.aculab.com> <87tvzy93ew.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "andrew@lunn.ch" <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:37260 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdISO3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 10:29:43 -0400
Received: by mail-io0-f195.google.com with SMTP id 93so5061204iol.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 07:29:43 -0700 (PDT)
In-Reply-To: <87tvzy93ew.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 19, 2017 7:19:35 AM PDT, Vivien Didelot <vivien=2Edidelot@savo=
irfairelinux=2Ecom> wrote:
>Hi David,
>
>David Laight <David=2ELaight@ACULAB=2ECOM> writes:
>
>> From: Florian Fainelli
>>> Sent: 18 September 2017 22:41
>>> Instead of repeating the same pattern: acquire mutex, read/write,
>release
>>> mutex, define a macro: b53_build_op() which takes the type
>(read|write), I/O
>>> size, and value (scalar or pointer)=2E This helps with fixing bugs
>that could
>>> exit (e=2Eg: missing barrier, lock etc=2E)=2E
>> =2E=2E=2E=2E
>>> +#define b53_build_op(type, op_size, val_type)	\
>>> +static inline int b53_##type##op_size(struct b53_device *dev, u8
>page,		\
>>> +				      u8 reg, val_type val)			\
>>> +{										\
>>> +	int ret;								\
>>> +										\
>>> +	mutex_lock(&dev->reg_mutex);						\
>>> +	ret =3D dev->ops->type##op_size(dev, page, reg, val);			\
>>> +	mutex_unlock(&dev->reg_mutex);						\
>>> +										\
>>> +	return ret;								\
>>>  }
>>
>> Why separate the 'type' and 'op_size' arguments since they
>> are always pasted together?
>
>For read/write48, the value type is u64=2E

The way I read David's comment is that instead of calling the macro with r=
ead, 48, just combine that in a single argument: read48=2E I don't have a p=
reference about that and can respin eventually=2E

--=20
Florian
