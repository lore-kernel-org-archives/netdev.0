From: David Miller <davem@davemloft.net>
Subject: Re: [jkirsher/next-queue PATCH v4 0/6] tc-flower based cloud
 filters in i40e
Date: Wed, 11 Oct 2017 14:19:29 -0700 (PDT)
Message-ID: <20171011.141929.2232480660433567821.davem@davemloft.net>
References: <20171011203832.GA9297@nanopsycho>
        <20171011.134652.1653141099248918341.davem@davemloft.net>
        <20171011205830.GD9297@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, amritha.nambiar@intel.com,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37018 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752034AbdJKVTb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:19:31 -0400
In-Reply-To: <20171011205830.GD9297@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 11 Oct 2017 22:58:30 +0200

> Well if I see classid, I expect it should refer to qdisc instance. So
> far, this has been always a case. But for some drivers, this would mean
> something totally different and unrelated. So what should I think?
> What's next? Classid could be abused to identify something else. I don't
> understand why.
> 
> classid in kernel and tclass in hw are 2 completely unrelated things.

Why do they need to be different?

It's qdisc instance in both cases.  The driver is just using it to
refer to the qdisc as offloaded in the hardware.  It's a key, nothing
more.  The context in which it is used doesn't change it's meaning.

> Why they should share the same userspace api? What am I missing that
> indicates this is not an abuse?

Why invent a completely new ID space to refer to something we exactly
have an ID for already?

This duplication for the sake of "API" makes no sense to me.

The handle is not going away.  It is not going to stop referring to
a specific qdisc.

So it's stable and appropriate to use to refer to a qdisc, whatever
operation being performed, or offload being we are going to perform of
it.

I notice you are quite feisty lately in your reviews of other people's
work, so I have to ask if things are very stressful in your life?
Please drink a nice warm cup of tea and calm down :-)
