From: "Liu Yu" <liuyums@bwstor.com.cn>
Subject: Wrong use of MAX_JIFFY_OFFSET?
Date: Tue, 27 Mar 2012 09:25:16 +0800
Message-ID: <000901cd0bb8$77fdc460$67f94d20$@com.cn>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.122.61.228] ([221.122.61.228]:37228 "EHLO mx.nrchpc.ac.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755762Ab2C0B7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 21:59:37 -0400
Received: from liuyumsPC ([221.122.61.228])
	(authenticated bits=0)
	by mx.nrchpc.ac.cn (8.13.8/8.13.8) with ESMTP id q2R1QpEd018155
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 09:26:52 +0800
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I saw a couple of places in current kernel have this kind of code:

> static inline unsigned int elapsed_jiffies_msecs(unsigned long start)
> {
>         unsigned long end = jiffies;
>
>         if (end >= start)
>                return jiffies_to_msecs(end - start);
>
>         return jiffies_to_msecs(end + (MAX_JIFFY_OFFSET - start) + 1);
> }

As you know, jiffies has a type of unsigned long, so if we know which is the
end and
which is the start, then (end - start) can simply figure out how much
jiffies flies,
without worry about the overflow.

Look at the code above, assume that there is just an overflow happening on
jiffies: end=0 and start=~0UL.
Since end < start, then the return value of the function is
jiffies_to_msecs(MAX_JIFFY_OFFSET+2).
But shouldn't the correct value be jiffies_to_msecs(1)?

could someone tell me that am I missing anything?

Thanks,
Yu
