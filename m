From: arkadis <arkadis@mellanox.com>
Subject: Re: [patch net-next RFC 0/8] Add support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 23:20:20 +0200
Message-ID: <0bcc0264-4877-9841-97e3-2b50d3e5077d@mellanox.com>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
 <20170216161150.GC17550@lunn.ch> <20170216162000.GF1968@nanopsycho>
 <20170216164029.GE17550@lunn.ch> <20170216164835.GH1968@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <idosch@mellanox.com>, <mlxsw@mellanox.com>, <jhs@mojatatu.com>,
        <ivecera@redhat.com>, <roopa@cumulusnetworks.com>,
        <f.fainelli@gmail.com>, <vivien.didelot@savoirfairelinux.com>,
        <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0044.outbound.protection.outlook.com ([104.47.0.44]:15474
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932975AbdBPVUd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 16:20:33 -0500
In-Reply-To: <20170216164835.GH1968@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/16/2017 06:48 PM, Jiri Pirko wrote:
> Thu, Feb 16, 2017 at 05:40:29PM CET, andrew@lunn.ch wrote:
>> On Thu, Feb 16, 2017 at 05:20:00PM +0100, Jiri Pirko wrote:
>>> Thu, Feb 16, 2017 at 05:11:50PM CET, andrew@lunn.ch wrote:
>>>> On Thu, Feb 16, 2017 at 04:22:36PM +0100, Jiri Pirko wrote:
>>>>> From: Jiri Pirko <jiri@mellanox.com>
>>>>>
>>>>> Arkadi says:
>>>>
>>>> Hi Jiri, Arkadi
>>>>
>>>> It is not mentioned here, but i assume you have a followup patchset
>>>> which extends the devlink command to enumerate what tables are
>>>> available and to print them?
>>>
>>> DEVLINK_CMD_DPIPE_TABLES_GET
>>> command gets you all tables. But it gets it with the content. I guess
>>> there could be some command to instruct devlink just to dump tables
>>> without the content.
>>
>> This does not sound like it will scale very well, as the number of
>> tables increases. Also, at least in the DSA world, getting a table can
>> be an expensive operation, lots of MDIO/SPI/I2C transactions. I'd
>> prefer to be able to just get one specific table, rather than dump
>> them all.
> 
> Understood. We'll try to figure out how to make this done.
> 

Get tables should give general table description including name,
behavior in terms of match/action, max entries, lookup way (TCAM, hash)
etc. To get the actual entries you have to use dump entries on a
per-table resolution. So you need to use DEVLINK_DPIPE_ENTRIES_GET on
a specific table.

First, one can see the tables in order to understand the hardware
structure (for debug purposes or just to gain visibility into the
offload process), and then dump the specific table of interest.

Some tables for example TCAM memory can be divided into regions.
So it is reasonable to aggregate tables under other tables (kind of
a zoom in) and be able to dump all the TCAM with one dump operation and
yet gain access of dumping each TCAM region separately.

Some things are currently missing like the above logic. Furthermore
the interaction between tables should be exported as well so that the
user receives graph of table interaction.

As I see it, all this behavior can be added and this basic API stays
valid.

> 
>>
>> I can however see cases when it does make sense to have an atomic,
>> dump everything operation, where you can trust to be consistent across
>> tables.
>>
>>>> Hopefully it will be more obvious when the user space patches are
>>>> available.
>>>
>>> I'll ask Arkadi to send the devlink userspace patches as RFC as well.
>>
>> Great, thanks.
>>
>>       Andrew
