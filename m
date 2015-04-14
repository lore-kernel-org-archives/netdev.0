From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4 07/24] switchdev: add port vlan obj
Date: Tue, 14 Apr 2015 00:28:40 -0700
Message-ID: <CAE4R7bBqJnKT+0Z_E8BLqsAX=g9WRtsZSgQAW2aVqcLcz4jZzg@mail.gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
	<1428905838-14920-8-git-send-email-sfeldma@gmail.com>
	<552C0190.8080606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:35918 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbbDNH2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 03:28:41 -0400
Received: by qku63 with SMTP id 63so3185699qku.3
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 00:28:40 -0700 (PDT)
In-Reply-To: <552C0190.8080606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 10:49 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 12/04/15 23:17, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> VLAN obj has flags (PVID and untagged) as well as start and end vid ranges.
>> The swdev driver can optimize programing the device using the ranges.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> ---
>>  include/net/switchdev.h |    8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> index f5f7733..d3cc8eb 100644
>> --- a/include/net/switchdev.h
>> +++ b/include/net/switchdev.h
>> @@ -45,12 +45,20 @@ struct fib_info;
>>
>>  enum swdev_obj_id {
>>       SWDEV_OBJ_UNDEFINED,
>> +     SWDEV_OBJ_PORT_VLAN,
>>  };
>>
>>  struct swdev_obj {
>>       enum swdev_obj_id id;
>>       enum swdev_trans trans;
>>       u32 flags;
>> +     union {
>> +             struct swdev_obj_vlan {                 /* PORT_VLAN */
>> +                     u16 flags;
>
> Should not we enforce some sort of definition of how we plan on using
> the "flags" member here?, if not, we might just as well remove it from
> this patch set until we actually use it?

removed in v5
