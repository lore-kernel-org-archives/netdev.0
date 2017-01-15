From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sat, 14 Jan 2017 17:57:12 -0800
Message-ID: <580590a9-d03b-2fab-efe7-173427b7c331@gmail.com>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
 <20170114162453.GB1072@lunn.ch>
 <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
 <1484445063.4555.8.camel@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: cugyly@163.com, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:33600 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750757AbdAOB5O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 20:57:14 -0500
Received: by mail-ot0-f196.google.com with SMTP id f9so3608709otd.0
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 17:57:14 -0800 (PST)
In-Reply-To: <1484445063.4555.8.camel@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/14/17 à 17:51, yuan linyu a écrit :
> On 六, 2017-01-14 at 10:35 -0800, Florian Fainelli wrote:
>> On 01/14/2017 08:24 AM, Andrew Lunn wrote:
>>>
>>> On Sat, Jan 14, 2017 at 10:46:31AM +0800, yuan linyu wrote:
>>>>
>>>> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>>>>
>>>> if phy device have register(s) configuration problem,
>>>> user can use this attribute to diagnose.
>>>> this feature need phy driver maintainer implement.
>>> what is wrong with mii-tool -vv ?
>> Agreed, and without an actual user of this API (ethtool?), nor a PHY
>> driver implementing it, we cannot quite see how you want to make use of
>> this.
> I hope user/developer can read this attribute file "regs" to do
> a full check of all registers value, and they can write any register
> inside PHY through this file.

You need to submit a PHY driver that implements the API you are
proposing here. Right now no PHY driver implements these {set,get}_regs
function pointers, so this is essentially dead code.

> 
> I think mii-tool or ethtool can't do it currently.

Maybe they cannot right now but they can certainly be patched to support
that. sysfs is not an appropriate interface for what you are proposing
here. We already have a set/get register via ethtool (-d/-D) it would
seem natural to use this.

Besides that, are not the current ioctl() good enough for that?
-- 
Florian
