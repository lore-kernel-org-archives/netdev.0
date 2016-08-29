From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/5] Make /sys/class/net per net namespace objects belong to container
Date: Mon, 29 Aug 2016 07:38:55 -0500
Message-ID: <87zinvpx5s.fsf@x220.int.ebiederm.org>
References: <1471386795-32918-1-git-send-email-dmitry.torokhov@gmail.com>
        <20160819.165917.2302741905893802825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: dmitry.torokhov@gmail.com, tj@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38295 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932763AbcH2MwW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 08:52:22 -0400
In-Reply-To: <20160819.165917.2302741905893802825.davem@davemloft.net> (David
        Miller's message of "Fri, 19 Aug 2016 16:59:17 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> Date: Tue, 16 Aug 2016 15:33:10 -0700
>
>> There are objects in /sys hierarchy (/sys/class/net/) that logically belong
>> to a namespace/container. Unfortunately all sysfs objects start their life
>> belonging to global root, and while we could change ownership manually,
>> keeping tracks of all objects that come and go is cumbersome. It would
>> be better if kernel created them using correct uid/gid from the beginning.
>> 
>> This series changes kernfs to allow creating object's with arbitrary
>> uid/gid, adds get_ownership() callback to ktype structure so subsystems
>> could supply their own logic (likely tied to namespace support) for
>> determining ownership of kobjects, and adjusts sysfs code to make use of
>> this information. Lastly net-sysfs is adjusted to make sure that objects in
>> net namespace are owned by the root user from the owning user namespace.
>> 
>> Note that we do not adjust ownership of objects moved into a new namespace
>> (as when moving a network device into a container) as userspace can easily
>> do it.
>
> I need some domain experts to review this series please.

I just came back from vacation and I will aim to take a look shortly.

The big picture idea seems sensible.  Having a better ownship of sysfs
files that are part of a network namespace.  I will have to look at the
details to see if the implementation is similarly sensible.

Eric
