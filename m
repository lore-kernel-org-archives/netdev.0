From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 5/7] openvswitch: Add original direction
 conntrack tuple to sw_flow_key.
Date: Tue, 7 Feb 2017 13:38:51 -0800
Message-ID: <CAPWQB7FaWJL3ncLOoY=KZXxBR=gQ8A4G5UCEY2OP=PBsAZzMaA@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org>
 <1486084206-109903-5-git-send-email-jarno@ovn.org> <CAPWQB7Hhm+dVqaOxU-56wV6MmDJw70716ir7cUAnxNnWs_a1LA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:41481 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932387AbdBGVj5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:39:57 -0500
Received: from mfilter15-d.gandi.net (mfilter15-d.gandi.net [217.70.178.143])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id BC8EDFB87D
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 22:39:14 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter15-d.gandi.net (mfilter15-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id L9EOFdFFeOLw for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 22:39:13 +0100 (CET)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com [209.85.216.170])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 24A33FB877
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 22:39:12 +0100 (CET)
Received: by mail-qt0-f170.google.com with SMTP id x49so147746402qtc.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 13:39:12 -0800 (PST)
In-Reply-To: <CAPWQB7Hhm+dVqaOxU-56wV6MmDJw70716ir7cUAnxNnWs_a1LA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 February 2017 at 23:15, Joe Stringer <joe@ovn.org> wrote:
> On 2 February 2017 at 17:10, Jarno Rajahalme <jarno@ovn.org> wrote:
>> @@ -79,9 +80,17 @@ static inline void ovs_ct_fill_key(const struct sk_buff *skb,
>>         key->ct.zone = 0;
>>         key->ct.mark = 0;
>>         memset(&key->ct.labels, 0, sizeof(key->ct.labels));
>> +       key->ct.orig_proto = 0;
>> +       key->ct.orig_tp.src = 0;
>> +       key->ct.orig_tp.dst = 0;
>> +       if (key->eth.type == htons(ETH_P_IP))
>> +               memset(&key->ipv4.ct_orig, 0, sizeof(key->ipv4.ct_orig));
>> +       else if (key->eth.type == htons(ETH_P_IPV6) && !sw_flow_key_is_nd(key))
>> +               memset(&key->ipv6.ct_orig, 0, sizeof(key->ipv6.ct_orig));
>
> If we only ever use these fields based on key->ct.orig_proto being
> nonzero, then we m

I think I had my email opened in two windows so truncated this
sentence somehow. I was wondering whether we can just initialize
key->ct.orig_proto and only init the others on demand.
