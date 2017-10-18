From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 4/7] devlink: Adding perm config of link settings
Date: Wed, 18 Oct 2017 16:04:13 +0200
Message-ID: <20171018140413.GE1975@nanopsycho.orion>
References: <1508273069-40461-1-git-send-email-steven.lin1@broadcom.com>
 <1508273069-40461-5-git-send-email-steven.lin1@broadcom.com>
 <20171018073151.GC2028@nanopsycho>
 <CA+Jmh7Eit_BBvkJNUdF4QYwCuP5T7WCkR4O_X9DK8O0CEzAjTA@mail.gmail.com>
 <20171018130108.GC1975@nanopsycho.orion>
 <CA+Jmh7HnZG+7xP=02K3BMKxODbfP=Mq=9o5iC2fS4LXw0+djMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>,
        Michael Chan <michael.chan@broadcom.com>,
        John Linville <linville@tuxdriver.com>,
        Andy Gospodarek <gospo@broadcom.com>
To: Steve Lin <steven.lin1@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:50813 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbdJROEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 10:04:15 -0400
Received: by mail-wr0-f195.google.com with SMTP id q42so5160917wrb.7
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 07:04:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Jmh7HnZG+7xP=02K3BMKxODbfP=Mq=9o5iC2fS4LXw0+djMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 18, 2017 at 03:22:03PM CEST, steven.lin1@broadcom.com wrote:
>On Wed, Oct 18, 2017 at 9:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Oct 18, 2017 at 02:39:42PM CEST, steven.lin1@broadcom.com wrote:
>>>On Wed, Oct 18, 2017 at 3:31 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>>
>>>> You need to split the config option to those that are per-port and to
>>>> those that are per-asic. For each family, you have to use ither
>>>> devlink_port of devlink handle. Also, you need to split into those that are
>>>> permanent and to those who are teporary (until reset). I think you might
>>>> need some flags for that.
>>>>
>>>
>>>All these are permanent; none are temporary - that's (partially) why
>>>we consider these to be devlink/device parameters rather than a
>>>netdev/ethtool thing, since they take effect after the next reset and
>>>before any drivers are loaded (i.e. the card uses these parameters for
>>>its default/startup configuration).
>>
>> Understood. But I think that this iface should be capable to serve the
>> options of non-permanent as well. Or this could be 2 separate interfaces
>> with 2 separate cmd pair. Thoughts?
>>
>
>I would prefer to keep this command for permanent config only, and use
>a separate command for transient configuration.  I think that
>transient device configuration should be tackled in the separate
>discussion that was started in the RFC version of this patchset,
>related to moving ethtool ops to devlink/netlink.
>
>I think that's a separate topic that requires a little more thought
>and discussion, but really isn't that related to this current patchset
>for permanent device configuration.  What do you think?

Makes sense. Then you need to clearly mark the cmds with "permanent"
keyword in name and enhance the description.
