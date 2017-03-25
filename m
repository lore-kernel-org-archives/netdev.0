From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more labels per route
Date: Sat, 25 Mar 2017 14:15:54 -0500
Message-ID: <87shm1np5h.fsf@xmission.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        rshearma@brocade.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60774 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdCYTqP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 15:46:15 -0400
In-Reply-To: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com> (David
        Ahern's message of "Sat, 25 Mar 2017 10:03:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> Bump the maximum number of labels for MPLS routes from 2 to 12. To keep
> memory consumption in check the labels array is moved to the end of mpls_nh
> and mpls_iptunnel_encap structs as a 0-sized array. Allocations use the
> maximum number of labels across all nexthops in a route for LSR and the
> number of labels configured for LWT.
>
> The mpls_route layout is changed to:
>
>    +----------------------+
>    | mpls_route           |
>    +----------------------+
>    | mpls_nh 0            |
>    +----------------------+
>    | alignment padding    |   4 bytes for odd number of labels; 0 for even
>    +----------------------+
>    | via[rt_max_alen] 0   |
>    +----------------------+
>    | alignment padding    |   via's aligned on sizeof(unsigned long)
>    +----------------------+
>    | ...                  |
>
> Meaning the via follows its mpls_nh providing better locality as the
> number of labels increases. UDP_RR tests with namespaces shows no impact
> to a modest performance increase with this layout for 1 or 2 labels and
> 1 or 2 nexthops.
>
> The new limit is set to 12 to cover all currently known segment
> routing use cases.

How does this compare with running the packet a couple of times through
the mpls table to get all of the desired labels applied?

I can certainly see the case in an mpls tunnel ingress where this might
could be desirable.    Which is something you implement in your last
patch.  However is it at all common to push lots of labels at once
during routing?

I am probably a bit naive but it seems absurd to push more
than a handful of labels onto a packet as you are routing it.

Eric
