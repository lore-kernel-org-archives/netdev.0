From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net V2] openvswitch: fix skb_panic due to the incorrect
 actions attrlen
Date: Tue, 15 Aug 2017 20:18:09 -0700
Message-ID: <CAOrHB_CS6TFuCo9OXWRa+n8gR5g-Ec-U7Gu_MtbTJhq9ogms=A@mail.gmail.com>
References: <20170815112913.14678-1-zlpnobody@163.com> <CAOrHB_CTHWMJEp_QG3EKn07sWk1QKPe8CEBx_4860u_GRKr12g@mail.gmail.com>
 <CAML_gOdF=7JAqK4Y8y_9t6t-ajHupHDkFF3wTW-bX28dHXcrPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Liping Zhang <zlpnobody@163.com>,
        Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Neil McKee <neil.mckee@inmon.com>
To: Liping Zhang <zlpnobody@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:58990 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752706AbdHPDSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 23:18:12 -0400
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id BE49841C086
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 05:18:10 +0200 (CEST)
Received: by mail-wm0-f44.google.com with SMTP id i66so23241372wmg.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 20:18:10 -0700 (PDT)
In-Reply-To: <CAML_gOdF=7JAqK4Y8y_9t6t-ajHupHDkFF3wTW-bX28dHXcrPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 6:44 PM, Liping Zhang <zlpnobody@gmail.com> wrote:
> 2017-08-16 7:35 GMT+08:00 Pravin Shelar <pshelar@ovn.org>:
> [...]
>>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>>> index e4610676299b..f849ef52853f 100644
>>> --- a/net/openvswitch/actions.c
>>> +++ b/net/openvswitch/actions.c
>>> @@ -921,6 +921,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>>>                         /* Include actions. */
>>>                         upcall.actions = actions;
>>>                         upcall.actions_len = actions_len;
>>> +                       upcall.actions_attrlen = OVS_CB(skb)->acts_origlen;
>> OVS_CB acts_origlen should be accessible in upcall_msg_size (), is
>> there reason to add this member to struct dp_upcall_info?
>
> Hmm... this means we should add an extra parameter to the upcall_msg_size()
> function, i.e.:
>  static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
> -                             unsigned int hdrlen)
> +                             unsigned int hdrlen, int actions_attrlen)
>
I am fine with the parameter.

Thanks.
