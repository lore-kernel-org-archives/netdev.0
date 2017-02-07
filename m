From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in
 ovs_ct_find_existing() if NATted.
Date: Mon, 6 Feb 2017 16:45:06 -0800
Message-ID: <CAPWQB7F79PjN_g9BBS7Og3Etqo368LLuh3vkKHNUiG489yifjw@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <20170205.172824.848224453582586032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:41680 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751618AbdBGApc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:45:32 -0500
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id CF50FC5A49
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 01:45:30 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id O_lSzvaX99bj for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 01:45:29 +0100 (CET)
Received: from mail-qt0-f175.google.com (mail-qt0-f175.google.com [209.85.216.175])
        (Authenticated sender: joe@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 5633CC5A50
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 01:45:28 +0100 (CET)
Received: by mail-qt0-f175.google.com with SMTP id v23so121420165qtb.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 16:45:28 -0800 (PST)
In-Reply-To: <20170205.172824.848224453582586032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5 February 2017 at 14:28, David Miller <davem@davemloft.net> wrote:
> From: Jarno Rajahalme <jarno@ovn.org>
> Date: Thu,  2 Feb 2017 17:10:00 -0800
>
>> This does not match either of the conntrack tuples above.  Normally
>> this does not matter, as the conntrack lookup was already done using
>> the tuple (B,A), but if the current packet does not match any flow in
>> the OVS datapath, the packet is sent to userspace via an upcall,
>> during which the packet's skb is freed, and the conntrack entry
>> pointer in the skb is lost.
>
> This is the real bug.
>
> If the metadata for a packet is important, as it obviously is here,
> then upcalls should preserve that metadata across the upcall.  This
> is exactly how NF_QUEUE handles this problem and so should OVS.

Looks like the patch #5 provides this preservation across upcall, so
this patch can be converted to use the key->ct.orig_* from that patch
instead of doing the invert.
