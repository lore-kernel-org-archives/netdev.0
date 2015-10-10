From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Fri, 9 Oct 2015 19:53:52 -0700
Message-ID: <CAE4R7bANc4rT3X_pCO5SSvDre7vvZ3+0VY43PZu9cpv020uayw@mail.gmail.com>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com> <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"vivien.didelot@savoirfairelinux.com"
	<vivien.didelot@savoirfairelinux.com>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:36748 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJJCyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 22:54:12 -0400
Received: by obcgx8 with SMTP id gx8so75620800obc.3
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 19:54:11 -0700 (PDT)
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 8, 2015 at 9:38 PM, Premkumar Jonnala <pjonnala@broadcom.com> wrote:
>
>
>> -----Original Message-----
>> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
>> Sent: Friday, October 09, 2015 7:53 AM
>> To: netdev@vger.kernel.org
>> Cc: davem@davemloft.net; jiri@resnulli.us; siva.mannem.lnx@gmail.com;
>> Premkumar Jonnala; stephen@networkplumber.org;
>> roopa@cumulusnetworks.com; andrew@lunn.ch; f.fainelli@gmail.com;
>> vivien.didelot@savoirfairelinux.com
>> Subject: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time down
>> to switchdev
>>
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
>> support setting ageing_time (or setting bridge attrs in general).
>>
>> If push fails, don't update ageing_time in bridge and return err to user.
>>
>> If push succeeds, update ageing_time in bridge and run gc_timer now to
>> recalabrate when to run gc_timer next, based on new ageing_time.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

<snip>

>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
>> +{
>> +     struct switchdev_attr attr = {
>> +             .id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>> +             .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>> +             .u.ageing_time = ageing_time,
>> +     };
>> +     unsigned long t = clock_t_to_jiffies(ageing_time);
>> +     int err;
>> +
>> +     if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>> +             return -ERANGE;
>> +
>> +     err = switchdev_port_attr_set(br->dev, &attr);
>
> A thought - given that the ageing time is not a per-bridge-port attr, why are we using a "port based api"
> to pass the attribute down?  May be I'm missing something here?

I think Florian raised the same point earlier.  Sigh, I think this
should be addressed....v4 coming soon...thanks guys for keeping the
standard high.
