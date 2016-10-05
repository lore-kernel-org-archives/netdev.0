From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] openvswitch: correctly fragment packet with mpls headers
Date: Tue, 4 Oct 2016 19:03:46 -0700
Message-ID: <CAOrHB_Cr7E+_GLtrReUqqG91LV_7yJSWoZhs0pe6N9E0rAxqPQ@mail.gmail.com>
References: <b0cb6efc9bfda8381af880f10fa6b3447f7d3d5d.1475512190.git.jbenc@redhat.com>
 <CAOrHB_Dh=OPUTbbN7QYo9Nz4cV99-k_fT4z7jSOEcnFEDKXQEg@mail.gmail.com>
 <20161004102458.1241605f@griffin> <20161004112804.04f25140@griffin>
 <CAOrHB_C55GM=AfYj43VJ-hPRZfwFxm_+8Ls2+7mck2Js1fy9-w@mail.gmail.com> <20161004185920.229e62de@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:46391 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753768AbcJECDv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 22:03:51 -0400
Received: from mfilter32-d.gandi.net (mfilter32-d.gandi.net [217.70.178.163])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id B498A1720A4
        for <netdev@vger.kernel.org>; Wed,  5 Oct 2016 04:03:49 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter32-d.gandi.net (mfilter32-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id cVfUqFrK6PTc for <netdev@vger.kernel.org>;
        Wed,  5 Oct 2016 04:03:48 +0200 (CEST)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com [209.85.214.50])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 5F4AF17209F
        for <netdev@vger.kernel.org>; Wed,  5 Oct 2016 04:03:48 +0200 (CEST)
Received: by mail-it0-f50.google.com with SMTP id 189so14093124ity.1
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 19:03:48 -0700 (PDT)
In-Reply-To: <20161004185920.229e62de@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 4, 2016 at 9:59 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 4 Oct 2016 09:53:25 -0700, Pravin Shelar wrote:
>> This code can be executed on encapsulated geneve or vxlan packets.
>
> How? The encapsulation header is in the form of metadata_dst at this
> point and not present in the packet itself. Am I missing something?
>

We could have encapsulated packet defragmented in physical bridge.
that mean the packet is entering OVS after egressing tunnel device.
That use case would break due to this patch.

> If this patch is wrong, then the current push_mpls is wrong, too, it
> does the same assumption.
>
I am not sure what you mean, can you explain?
