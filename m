From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v2 1/4] net: Introduce psample, a new genetlink
 channel for packet sampling
Date: Tue, 24 Jan 2017 12:48:54 +0100
Message-ID: <20170124114853.GA16485@penelope.horms.nl>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
 <1485166031-4773-2-git-send-email-jiri@resnulli.us>
 <20170124083203.GA25022@penelope.horms.nl>
 <20170124083734.GB1891@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37113 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750785AbdAXLs6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 06:48:58 -0500
Received: by mail-wm0-f48.google.com with SMTP id c206so204944280wme.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 03:48:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170124083734.GB1891@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 09:37:34AM +0100, Jiri Pirko wrote:
> Tue, Jan 24, 2017 at 09:32:05AM CET, simon.horman@netronome.com wrote:
> >On Mon, Jan 23, 2017 at 11:07:08AM +0100, Jiri Pirko wrote:
> >> From: Yotam Gigi <yotamg@mellanox.com>
> >> 
> >> Add a general way for kernel modules to sample packets, without being tied
> >> to any specific subsystem. This netlink channel can be used by tc,
> >> iptables, etc. and allow to standardize packet sampling in the kernel.
> >> 
> >> For every sampled packet, the psample module adds the following metadata
> >> fields:
> >> 
> >> PSAMPLE_ATTR_IIFINDEX - the packets input ifindex, if applicable
> >> 
> >> PSAMPLE_ATTR_OIFINDEX - the packet output ifindex, if applicable
> >> 
> >> PSAMPLE_ATTR_ORIGSIZE - the packet's original size, in case it has been
> >>    truncated during sampling
> >> 
> >> PSAMPLE_ATTR_SAMPLE_GROUP - the packet's sample group, which is set by the
> >>    user who initiated the sampling. This field allows the user to
> >>    differentiate between several samplers working simultaneously and
> >>    filter packets relevant to him
> >> 
> >> PSAMPLE_ATTR_GROUP_SEQ - sequence counter of last sent packet. The
> >>    sequence is kept for each group
> >> 
> >> PSAMPLE_ATTR_SAMPLE_RATE - the sampling rate used for sampling the packets
> >> 
> >> PSAMPLE_ATTR_DATA - the actual packet bits
> >> 
> >> The sampled packets are sent to the PSAMPLE_NL_MCGRP_SAMPLE multicast
> >> group. In addition, add the GET_GROUPS netlink command which allows the
> >> user to see the current sample groups, their refcount and sequence number.
> >> This command currently supports only netlink dump mode.
> >> 
> >> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> >> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >> Reviewed-by: Jamal Hadi Salim <jhs@mojatatu.com>
> >
> >Hi Jiri, Hi Yotam,
> >
> >this looks good to me.
> >
> >Reviewed-by: Simon Horman <simon.horman@netronome.com>
> >
> >I do, however, have one question: what is your feeling about allowing
> >the per-action cooking which Jamal has proposed[1] to be emited as
> >metadata as another PSAMPLE_ATTR_* attribute? For one thing I think it
> >would allow for smooth integration with OvS user-space which makes use of a
> >cookie.
> 
> Yeah, cookie could be easily added.

Great. We can address that as follow-up work at some point.
