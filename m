From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Wed, 12 Dec 2012 18:30:51 +0100
Message-ID: <50C8BF4B.6030801@6wind.com>
References: <50BE56D3.2030704@6wind.com> <50BF29DA.7020903@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70DA@saturn3.aculab.com> <20121205.125453.1457654258131828976.davem@davemloft.net> <50C05AC2.1050504@6wind.com> <20121206174905.GC16122@casper.infradead.org> <50C74B5D.9050708@6wind.com> <20121211184013.GD27746@casper.infradead.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49631 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab2LLRaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:30:55 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so533426bkw.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 09:30:53 -0800 (PST)
In-Reply-To: <20121211184013.GD27746@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/12/2012 19:40, Thomas Graf a =E9crit :
> On 12/11/12 at 04:03pm, Nicolas Dichtel wrote:
>> In fact, it seems not so easy because most users of nlmsg_new() calc=
ulate
>> the exact needed length, thus if we add an unpredicted attribute,
>> the message will be too small.
>
> True, we would either need to fix the calculations by accounting
> for an additional 4 bytes for each 64bit arg or just reserve an
> additional fixed amount for padding per message in nlmsg_new().
>
I would say that reserving additional space is better, because we also
need to align attributes that contain u64 fields:

struct attribute_foo {
    __u32 bar;
    __u32 bar2;
    __u64 foo;
};

I wonder if it is better to align all attribute on 64-bits or only u64 =
and
add a new function nla_put_align64() for attribute with u64 fields.
