From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 19 Apr 2017 15:05:07 +0200
Message-ID: <20170419130507.GD3357@nanopsycho.orion>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
 <85shl4o8te.fsf@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
        netdev@vger.kernel.org, eric.dumazet@gmail.com,
        xiyou.wangcong@gmail.com
To: Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33622 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763282AbdDSNFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 09:05:11 -0400
Received: by mail-wr0-f196.google.com with SMTP id l28so3154885wre.0
        for <netdev@vger.kernel.org>; Wed, 19 Apr 2017 06:05:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <85shl4o8te.fsf@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 19, 2017 at 02:55:57PM CEST, mrv@mojatatu.com wrote:
>Jiri Pirko <jiri@resnulli.us> writes:
>
>
>[...]
>
>>>+enum {
>>>+	TCAA_UNSPEC,
>>>+	TCAA_ACT_TAB,
>>>+	TCAA_ACT_FLAGS,
>>>+	TCAA_ACT_COUNT,
>>>+	__TCAA_MAX
>>>+};
>>>+
>>>+#define TCAA_MAX (__TCAA_MAX - 1)
>>> #define TA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcamsg))))
>>> #define TA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcamsg))
>>>-#define TCA_ACT_TAB 1 /* attr type must be >=1 */	
>>>-#define TCAA_MAX 1
>>>+#define TCA_ACT_TAB TCAA_ACT_TAB
>>
>> This is mess. What does "TCAA" stand for?
>> I suggest some more meaningful naming of the enum items and define
>> TCA_ACT_TAB and TCAA_MAX to the new values in order to maintain UAPI
>> Also, please put X_MAX = __X_MAX - 1 into enum
>>
>
>Notation observed in tc and unfortunately not consistently maintained is
>to have enum with TCA* attributes for instance, followed by define,
>outside of the enum, with __X_MAX -1

I don't have strong opinion on define or in-enum. I like in-enum better.
The rest could be converted later on.
