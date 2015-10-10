From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time
 down to switchdev
Date: Sat, 10 Oct 2015 09:04:34 +0200
Message-ID: <20151010070434.GB1990@nanopsycho.orion>
References: <1444357400-37078-1-git-send-email-sfeldma@gmail.com>
 <1444357400-37078-4-git-send-email-sfeldma@gmail.com>
 <77EF4405DD4BB54AACCE7DB593DF6A9A9F6596@SJEXCHMB14.corp.ad.broadcom.com>
 <CAE4R7bANc4rT3X_pCO5SSvDre7vvZ3+0VY43PZu9cpv020uayw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"vivien.didelot@savoirfairelinux.com"
	<vivien.didelot@savoirfairelinux.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36725 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbbJJHEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 03:04:36 -0400
Received: by wicgb1 with SMTP id gb1so93531726wic.1
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 00:04:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bANc4rT3X_pCO5SSvDre7vvZ3+0VY43PZu9cpv020uayw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Oct 10, 2015 at 04:53:52AM CEST, sfeldma@gmail.com wrote:
>On Thu, Oct 8, 2015 at 9:38 PM, Premkumar Jonnala <pjonnala@broadcom.com> wrote:
>>
>>
>>> -----Original Message-----
>>> From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
>>> Sent: Friday, October 09, 2015 7:53 AM
>>> To: netdev@vger.kernel.org
>>> Cc: davem@davemloft.net; jiri@resnulli.us; siva.mannem.lnx@gmail.com;
>>> Premkumar Jonnala; stephen@networkplumber.org;
>>> roopa@cumulusnetworks.com; andrew@lunn.ch; f.fainelli@gmail.com;
>>> vivien.didelot@savoirfairelinux.com
>>> Subject: [PATCH net-next v3 3/4] bridge: push bridge setting ageing_time down
>>> to switchdev
>>>
>>> From: Scott Feldman <sfeldma@gmail.com>
>>>
>>> Use SWITCHDEV_F_SKIP_EOPNOTSUPP to skip over ports in bridge that don't
>>> support setting ageing_time (or setting bridge attrs in general).
>>>
>>> If push fails, don't update ageing_time in bridge and return err to user.
>>>
>>> If push succeeds, update ageing_time in bridge and run gc_timer now to
>>> recalabrate when to run gc_timer next, based on new ageing_time.
>>>
>>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
><snip>
>
>>> +int br_set_ageing_time(struct net_bridge *br, u32 ageing_time)
>>> +{
>>> +     struct switchdev_attr attr = {
>>> +             .id = SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>>> +             .flags = SWITCHDEV_F_SKIP_EOPNOTSUPP,
>>> +             .u.ageing_time = ageing_time,
>>> +     };
>>> +     unsigned long t = clock_t_to_jiffies(ageing_time);
>>> +     int err;
>>> +
>>> +     if (t < BR_MIN_AGEING_TIME || t > BR_MAX_AGEING_TIME)
>>> +             return -ERANGE;
>>> +
>>> +     err = switchdev_port_attr_set(br->dev, &attr);
>>
>> A thought - given that the ageing time is not a per-bridge-port attr, why are we using a "port based api"
>> to pass the attribute down?  May be I'm missing something here?
>
>I think Florian raised the same point earlier.  Sigh, I think this
>should be addressed....v4 coming soon...thanks guys for keeping the
>standard high.

Scott, can you tell us how do you want to address this? I like the
current implementation.
