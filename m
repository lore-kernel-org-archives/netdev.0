From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more
 labels per route
Date: Tue, 28 Mar 2017 08:39:42 -0600
Message-ID: <ef8c79ec-11e2-680b-8be5-c1476bf95a7d@cumulusnetworks.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
 <87shm1np5h.fsf@xmission.com>
 <5fe416c3-3e56-4e31-f92b-33e3e7b2e3c0@brocade.com>
 <608c60ac-7669-86f0-b0ef-02add5287009@cumulusnetworks.com>
 <871stiayie.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org,
        roopa@cumulusnetworks.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:35071 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751712AbdC1Oj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:39:59 -0400
Received: by mail-pg0-f41.google.com with SMTP id 81so60108634pgh.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:39:53 -0700 (PDT)
In-Reply-To: <871stiayie.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/27/17 9:08 PM, Eric W. Biederman wrote:
> 
> Overall I like what is being accomplished by this patchset.
> I especially like the fact that the forwarding path is left
> essentially unchanged, and that the struct mpls_route shirnks a little
> for the common case.
> 
> I believe we should just kill MAX_NEW_LABELS.
> 
> I think the only significant change from your patch is the removal of an
> array from mpls_route_config.
> 
> With the removal of MAX_NEW_LABELS I would replace it by a sanity check
> in mpls_rt_alloc that verifies that the amount we are going to allocate
> for struct mpls_route is < PAGE_SIZE.  Anything larger is just
> asking for trouble.

Sure. We would want a consistent API across architectures. As I recall
some of them have 64kB page sizes, so rather than page size let's limit
to the number 4096 rather than PAGE_SIZE.

> 
> That should put our practical limit just a little bit below 32 nexthops
> adding 32 labels each.

I send out a v2 soon.
