From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Clarification regarding IFLA_BRPORT_LEARNING_SYNC and aging of
 fdb entries learnt via br_fdb_external_learn_add()
Date: Wed, 7 Jan 2015 13:53:01 +0100
Message-ID: <20150107125301.GE1888@nanopsycho.orion>
References: <CA+CtxLSv6Hg9kOmavqQKs+7y8b8+TBdW1dYwb3ZsTMOh=Ow8Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: Siva Mannem <siva.mannem.lnx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:61964 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbAGMxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 07:53:04 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so1096192wgg.26
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 04:53:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CA+CtxLSv6Hg9kOmavqQKs+7y8b8+TBdW1dYwb3ZsTMOh=Ow8Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 30, 2014 at 07:20:21PM CET, siva.mannem.lnx@gmail.com wrote:
>Hi,
>
>I am trying to understand the ongoing switch device offload effort and
>am following the discussions. I have a question regarding
>IFLA_BRPORT_LEARNING_SYNC flag and how aging happens when this flag is
>enabled on a port that is attached to a bridge that has vlan filtering
>enabled.
>
>If I understand correctly, when  IFLA_BRPORT_LEARNING_SYNC is set on a
>bridge port, fdb entries that are learnt externally(may be learnt by
>hardware and driver is notified) are synced to bridges fdb using
>br_fdb_external_learn_add(). The fdb
>entries(fdb->added_by_external_learn set to true) that are learnt via
>this method are also deleted by the aging logic after the aging time
>even though L2 data forwadring  happens in hardware. Is there a way
>where aging can be disabled for these entries? and let the entries be
>removed only via br_fdb_external_learn_delete()? or am I missing
>something?

Currently extenaly learned fdb entries are indeed removed during aging
cleanup. I believe that br_fdb_cleanup should check added_by_external_learn
and not remove that fdbs. What do you think Scott?
