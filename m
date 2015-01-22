From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] tc: introduce OpenFlow classifier
Date: Thu, 22 Jan 2015 17:16:00 +0100
Message-ID: <20150122161600.GD1863@nanopsycho.orion>
References: <1421933824-17916-1-git-send-email-jiri@resnulli.us>
 <54C11C4A.1070206@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:62015 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbbAVQQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 11:16:03 -0500
Received: by mail-wi0-f170.google.com with SMTP id em10so22698718wid.1
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 08:16:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54C11C4A.1070206@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 22, 2015 at 04:50:34PM CET, jhs@mojatatu.com wrote:
>On 01/22/15 08:37, Jiri Pirko wrote:
>>This patch introduces OpenFlow-based filter. So far, the very essential
>>packet fields are supported (according to OpenFlow v1.4 spec).
>>
>>Known issues: skb_flow_dissect hashes out ipv6 addresses. That needs
>>to be changed to store them somewhere so they can be used later on.
>>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>---
>>  include/uapi/linux/pkt_cls.h |  33 +++
>>  net/sched/Kconfig            |  11 +
>>  net/sched/Makefile           |   1 +
>>  net/sched/cls_openflow.c     | 514 +++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 559 insertions(+)
>>  create mode 100644 net/sched/cls_openflow.c
>>
>>diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>>index 25731df..d4cef16 100644
>>--- a/include/uapi/linux/pkt_cls.h
>>+++ b/include/uapi/linux/pkt_cls.h
>>@@ -402,6 +402,39 @@ enum {
>>
>>  #define TCA_BPF_MAX (__TCA_BPF_MAX - 1)
>>
>>+/* OpenFlow classifier */
>>+
>>+enum {
>>+	TCA_OF_UNSPEC,
>>+	TCA_OF_CLASSID,
>>+	TCA_OF_POLICE,
>>+	TCA_OF_INDEV,
>
>I think POLICE is an old way of doing policing and INDEV if i am not
>mistaken is only legit for u32 classifier.
>So i am not sure you want to keep them.

I use INDEV for matching skb input device. I can move this to
TCA_OF_KEY_INDEV but since I spotted TCA_*_INDEV, I made this to be the
same.

The POLICE, I just copied from the other cls's

>
>Other than that looks good - will be interested to see how perfomance looks
>on this with the list walking ;->

I plan to do some optimizations as follow-ups. (hash list for example)

>
>cheers,
>jamal
