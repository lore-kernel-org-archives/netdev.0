From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2 1/2] net: sched: make default fifo qdiscs appear in
 the dump
Date: Wed, 8 Mar 2017 15:57:33 +0100
Message-ID: <20170308145733.GL1919@nanopsycho>
References: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35211 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751132AbdCHO5i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 09:57:38 -0500
Received: by mail-wr0-f195.google.com with SMTP id u108so4462079wrb.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 06:57:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.20.1703081302240.31814@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 08, 2017 at 01:03:42PM CET, jikos@kernel.org wrote:
>From: Jiri Kosina <jkosina@suse.cz>
>
>The original reason [1] for having hidden qdiscs (potential scalability
>issues in qdisc_match_from_root() with single linked list in case of large
>amount of qdiscs) has been invalidated by 59cc1f61f0 ("net: sched: convert
>qdisc linked list to hashtable").
>
>This allows us for bringing more clarity and determinism into the dump by
>making default pfifo qdiscs visible.
>
>We're not turning this on by default though, at it was deemed [2] too
>intrusive / unnecessary change of default behavior towards userspace.
>Instead, TCA_DUMP_INVISIBLE netlink attribute is introduced, which allows
>applications to request complete qdisc hierarchy dump, including the
>ones that have always been implicit/invisible.
>
>Singleton noop_qdisc stays invisible, as teaching the whole infrastructure
>about singletons would require quite some surgery with very little gain
>(seeing no qdisc or seeing noop qdisc in the dump is probably setting
>the same user expectation).
>
>[1] http://lkml.kernel.org/r/1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com
>[2] http://lkml.kernel.org/r/20161021.105935.1907696543877061916.davem@davemloft.net
>
>Signed-off-by: Jiri Kosina <jkosina@suse.cz>
>---

[...]


>diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
>index 262f0379d83a..c7de00e09797 100644
>--- a/include/uapi/linux/rtnetlink.h
>+++ b/include/uapi/linux/rtnetlink.h
>@@ -542,6 +542,7 @@ enum {
> 	TCA_FCNT,
> 	TCA_STATS2,
> 	TCA_STAB,
>+	TCA_DUMP_INVISIBLE,
> 	TCA_PAD,

You are changing UAPI value of TCA_PAD...


> 	__TCA_MAX
> };
