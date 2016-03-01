From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 10:51:53 -0800
Message-ID: <CAM_iQpXDo5Lh+MF7yds3vDyn7D-aqKH3-9kmVYZ924QkAw=imA@mail.gmail.com>
References: <20160301174233.GO16369@oracle.com>
	<CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
	<20160301182102.GR16369@oracle.com>
	<CAM_iQpXwd9fQqEh1o56fVqoxUYC5ctY9wqjkAA7UeGru+T8bjw@mail.gmail.com>
	<20160301184119.GS16369@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:34222 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbcCASvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:51:54 -0500
Received: by mail-yk0-f176.google.com with SMTP id u9so81234639ykd.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 10:51:54 -0800 (PST)
In-Reply-To: <20160301184119.GS16369@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 10:41 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/01/16 10:23), Cong Wang wrote:
>> > The compiler error is for fields within the union which lacks
>> > both a tag and a union-name.  So I'm not sure how the above will
>> > help.
>> >
>>
>> Come on.. we have plenty of such anonymous unions in skbuff.h...
>
> I realize that, even netdevice.h itself has other instances.
> Thus I dont understand why this one generated a compiler error
> for me.  Thus I was wondering why others had not run into this
> and not suggesting it should be patched.
>
> However, changing the way we set up type etc. doesnt seem relevant
> to what the compiler is flagging.
>

Clearly the compiler indicates something is wrong in the initializer.

I don't know why you don't want to try the way I suggest or maybe
the following:

diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index f9947d1..77743e8 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -142,7 +142,7 @@ static int mqprio_init(struct Qdisc *sch, struct
nlattr *opt)
         */
        if (qopt->hw) {
                struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
-                                         .tc = qopt->num_tc};
+                                         {.tc = qopt->num_tc} };

                priv->hw_owned = 1;
                err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
