From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v4 3/4] ifstat: Add 64 bits based stats to extended
 statistics
Date: Thu, 19 Jan 2017 08:06:21 -0800
Message-ID: <5880E3FD.6010604@cumulusnetworks.com>
References: <1484228991-32999-1-git-send-email-nogahf@mellanox.com> <1484228991-32999-4-git-send-email-nogahf@mellanox.com> <20170112174335.1bd391c2@xeon-e3> <DB5PR05MB1895D7CFBE9E127AAAE672DBAC7E0@DB5PR05MB1895.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Elad Raz <eladr@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35550 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753153AbdASQGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:06:23 -0500
Received: by mail-pg0-f51.google.com with SMTP id 194so15251647pgd.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 08:06:23 -0800 (PST)
In-Reply-To: <DB5PR05MB1895D7CFBE9E127AAAE672DBAC7E0@DB5PR05MB1895.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/17, 7:21 AM, Nogah Frankel wrote:
>> -----Original Message-----
>> From: Nogah Frankel
>> Sent: Sunday, January 15, 2017 3:55 PM
>> To: 'Stephen Hemminger' <stephen@networkplumber.org>
>> Cc: netdev@vger.kernel.org; roszenrami@gmail.com; roopa@cumulusnetworks.com; Jiri
>> Pirko <jiri@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad Raz
>> <eladr@mellanox.com>; Yotam Gigi <yotamg@mellanox.com>; Or Gerlitz
>> <ogerlitz@mellanox.com>
>> Subject: RE: [PATCH iproute2 v4 3/4] ifstat: Add 64 bits based stats to extended statistics
>>
>>
>>
>>> -----Original Message-----
>>> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
>>> Sent: Friday, January 13, 2017 3:44 AM
>>> To: Nogah Frankel <nogahf@mellanox.com>
>>> Cc: netdev@vger.kernel.org; roszenrami@gmail.com; roopa@cumulusnetworks.com;
>> Jiri
>>> Pirko <jiri@mellanox.com>; Ido Schimmel <idosch@mellanox.com>; Elad Raz
>>> <eladr@mellanox.com>; Yotam Gigi <yotamg@mellanox.com>; Or Gerlitz
>>> <ogerlitz@mellanox.com>
>>> Subject: Re: [PATCH iproute2 v4 3/4] ifstat: Add 64 bits based stats to extended statistics
>>>
>>> On Thu, 12 Jan 2017 15:49:50 +0200
>>> Nogah Frankel <nogahf@mellanox.com> wrote:
>>>
>>>> The default stats for ifstat are 32 bits based.
>>>> The kernel supports 64 bits based stats. (They are returned in struct
>>>> rtnl_link_stats64 which is an exact copy of struct rtnl_link_stats, in
>>>> which the "normal" stats are returned, but with fields of u64 instead of
>>>> u32). This patch adds them as an extended stats.
>>>>
>>>> It is read with filter type IFLA_STATS_LINK_64 and no sub type.
>>>>
>>>> It is under the name 64bits
>>>> (or any shorten of it as "64")
>>>>
>>>> For example:
>>>> ifstat -x 64bit
>>>>
>>>> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
>>>> Reviewed-by: Jiri Pirko <jiri@mellanox.com>
>>> Other commands (like ip link) always use the 64 bit statistics if available
>>> from the device. I see no reason that ifstat needs to be different.
>>>
>> Do you mean to change the default ifstat results to be 64 bits based?
>> I tried it in the first version, but Roopa commented that it was not a good idea.
>> She said they tried it in the past and it caused backward compatibilities problems.
>> (Or maybe I didn't understand correctly)
> So, can I leave the default ifstat results to be 32 bits based, for the time being?
>
>From past discussions: Moving the default to 64bit has compat issues with the old history file.
There is a way to make it work by using a new file header (to indicate that it is 64 bit) in
a freshly created history file and also check this header before dumping stats into the history file.
ie maintain backward compat without introducing a new option. It is doable.

One approach is, you can drop the 64bit option from this series and
try updating the default to 64 bit (with compat handling code) in a later series.
