From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 4 Dec 2010 23:01:38 +0800
Message-ID: <AANLkTi=VESSzNvq_VwkWVU5b13VwnGs_tJn-4mqB28LV@mail.gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com> <4CFA3F01.20109@gmail.com>
 <1291472889.2159.18.camel@mojatatu> <AANLkTimy_dK0uDCWqo3AZBKSvod+KnE6Om-CxrbFmPj+@mail.gmail.com>
 <1291474504.2159.39.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55466 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab0LDPCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 10:02:00 -0500
Received: by fxm20 with SMTP id 20so3059501fxm.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 07:01:59 -0800 (PST)
In-Reply-To: <1291474504.2159.39.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 4, 2010 at 10:55 PM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2010-12-04 at 22:45 +0800, Changli Gao wrote:
>
>>
>> If we breaks the loop when there are still skbs in tq and no skb in
>> rq, the skbs will be left in txq until new skbs are enqueued into rq.
>> In rare cases, no new skb is queued, then these skbs will stay in rq
>> forever.
>
> So should we goto resched?
>

Only if we can't lock the txq or rq isn't empty, we goto resched. So
it is a bug.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
