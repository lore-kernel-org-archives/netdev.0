From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch net-next v3 01/10] net: sched: move tc_classify function
 to cls_api.c
Date: Tue, 16 May 2017 14:03:14 -0700
Message-ID: <CAM_iQpWgtqBYEPTcdKqx=52kpmLTUug173Zdq+7gS-pniswy_A@mail.gmail.com>
References: <20170516172802.1317-1-jiri@resnulli.us> <20170516172802.1317-2-jiri@resnulli.us>
 <CAM_iQpVqRTcK0H3wSiUEOXSk+pWtriSLFy7jtN6d77wrTjqe3Q@mail.gmail.com> <20170516210038.GR1939@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Simon Horman <simon.horman@netronome.com>, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33321 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750799AbdEPVDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 17:03:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id y10so40869831wmh.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 14:03:35 -0700 (PDT)
In-Reply-To: <20170516210038.GR1939@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 2:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, May 16, 2017 at 10:25:35PM CEST, xiyou.wangcong@gmail.com wrote:
>>On Tue, May 16, 2017 at 10:27 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> From: Jiri Pirko <jiri@mellanox.com>
>>>
>>> Move tc_classify function to cls_api.c where it belongs, rename it to
>>> fit the namespace.
>>>
>>
>>It is not a pure move, you silently remove the CONFIG_NET_CLS_ACT
>>macros in tc_classify(). Probably not buggy, just redundancy when
>>actions are not compiled.
>
> Plese see include/net/pkt_cls.h in this patch.
>
> If CONFIG_NET_CLS_ACT is not defined, there is a stub there.

I am sure it is not NET_CLS_ACT:


#ifdef CONFIG_NET_CLS
 void tcf_destroy_chain(struct tcf_proto __rcu **fl);
+int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+                struct tcf_result *res, bool compat_mode);
+
 #else
 static inline void tcf_destroy_chain(struct tcf_proto __rcu **fl)
 {
 }
+
+static inline int tcf_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+                              struct tcf_result *res, bool compat_mode)
+{
+       return TC_ACT_UNSPEC;
+}
 #endif
