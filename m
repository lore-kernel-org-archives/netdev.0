From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with mpls headers
Date: Tue, 4 Oct 2016 09:53:25 -0700
Message-ID: <CAOrHB_C55GM=AfYj43VJ-hPRZfwFxm_+8Ls2+7mck2Js1fy9-w@mail.gmail.com>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
 <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
 <20161004102458.1241605f@griffin> <20161004112804.04f25140@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:49703 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752027AbcJDQxb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 12:53:31 -0400
Received: from mfilter49-d.gandi.net (mfilter49-d.gandi.net [217.70.178.180])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id BF6E3A80E5
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 18:53:28 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter49-d.gandi.net (mfilter49-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id oog2BaNOKaPU for <netdev@vger.kernel.org>;
        Tue,  4 Oct 2016 18:53:27 +0200 (CEST)
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 3A80FA80C0
        for <netdev@vger.kernel.org>; Tue,  4 Oct 2016 18:53:27 +0200 (CEST)
Received: by mail-io0-f175.google.com with SMTP id i202so78641295ioi.2
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 09:53:27 -0700 (PDT)
In-Reply-To: <20161004112804.04f25140@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 4, 2016 at 2:28 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 4 Oct 2016 10:24:58 +0200, Jiri Benc wrote:
>> On Mon, 3 Oct 2016 11:04:46 -0700, Pravin Shelar wrote:
>> > This is not correct way to detect MPLS packet. inner_protocol can be
>> > set by any tunnel device for using tunnel offloads. So this would
>> > break the fragmentation for encapsulated packets.
>>
>> You're right, stupid me.
>
> Actually, too little caffeine in the morning. I actually did consider
> this and I believe my patch is correct. It doesn't matter what the
> encapsulation is, we want to fragment the *inner* packet. And this is
> exactly what this patch does.
>
> Besides, the only case is MPLS anyway. I'm not aware of any code path
> that could lead us to here, set inner protocol and not be MPLS. But
> even if it is, it should work, provided the encapsulation header is
> identical for all fragments and smaller than MAX_L2_LEN.
>

This code can be executed on encapsulated geneve or vxlan packets. So
in that case encapsulation header would not be same for all fragments.
