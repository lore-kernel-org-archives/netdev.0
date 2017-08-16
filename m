From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH net V2] openvswitch: fix skb_panic due to the incorrect
 actions attrlen
Date: Wed, 16 Aug 2017 09:44:56 +0800
Message-ID: <CAML_gOdF=7JAqK4Y8y_9t6t-ajHupHDkFF3wTW-bX28dHXcrPw@mail.gmail.com>
References: <20170815112913.14678-1-zlpnobody@163.com> <CAOrHB_CTHWMJEp_QG3EKn07sWk1QKPe8CEBx_4860u_GRKr12g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Liping Zhang <zlpnobody@163.com>,
        Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Neil McKee <neil.mckee@inmon.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36767 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752694AbdHPBo5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 21:44:57 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so3981657pgy.3
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 18:44:57 -0700 (PDT)
In-Reply-To: <CAOrHB_CTHWMJEp_QG3EKn07sWk1QKPe8CEBx_4860u_GRKr12g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-08-16 7:35 GMT+08:00 Pravin Shelar <pshelar@ovn.org>:
[...]
>> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
>> index e4610676299b..f849ef52853f 100644
>> --- a/net/openvswitch/actions.c
>> +++ b/net/openvswitch/actions.c
>> @@ -921,6 +921,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>>                         /* Include actions. */
>>                         upcall.actions = actions;
>>                         upcall.actions_len = actions_len;
>> +                       upcall.actions_attrlen = OVS_CB(skb)->acts_origlen;
> OVS_CB acts_origlen should be accessible in upcall_msg_size (), is
> there reason to add this member to struct dp_upcall_info?

Hmm... this means we should add an extra parameter to the upcall_msg_size()
function, i.e.:
 static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
-                             unsigned int hdrlen)
+                             unsigned int hdrlen, int actions_attrlen)

So which one do you prefer? If the latter, I can send V3.
