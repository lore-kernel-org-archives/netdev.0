From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next 1/7] openvswitch: Use inverted tuple in
 ovs_ct_find_existing() if NATted.
Date: Mon, 6 Feb 2017 09:06:29 -0800
Message-ID: <CAOrHB_AWB7MFEHpeuKcG21s9QWjMHKC2zWNmXQLDo_5KZrnY6w@mail.gmail.com>
References: <1486084206-109903-1-git-send-email-jarno@ovn.org> <20170205.172824.848224453582586032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:38203 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBFRGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 12:06:35 -0500
Received: from mfilter43-d.gandi.net (mfilter43-d.gandi.net [217.70.178.174])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 7F086C5A86
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:06:32 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter43-d.gandi.net (mfilter43-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id hJwXPHER5h9K for <netdev@vger.kernel.org>;
        Mon,  6 Feb 2017 18:06:31 +0100 (CET)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id EB009C5A8B
        for <netdev@vger.kernel.org>; Mon,  6 Feb 2017 18:06:30 +0100 (CET)
Received: by mail-it0-f43.google.com with SMTP id r185so61336844ita.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 09:06:30 -0800 (PST)
In-Reply-To: <20170205.172824.848224453582586032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 5, 2017 at 2:28 PM, David Miller <davem@davemloft.net> wrote:
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

OVS kernel datapath serializes skb context and sends it along with skb
during upcall via genetlink parameters. userspace echoes same
information back to kernel modules. This way OVS does maintains
metadata across upcall.
