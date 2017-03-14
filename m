From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH] net: mpls: Fix nexthop alive tracking on down events
Date: Tue, 14 Mar 2017 10:29:16 +0000
Message-ID: <d38589fb-89a1-13e4-1754-dd4e75ff5707@brocade.com>
References: <1489448950-13340-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60568 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750785AbdCNK33 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 06:29:29 -0400
In-Reply-To: <1489448950-13340-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/17 23:49, David Ahern wrote:
> Alive tracking of nexthops can account for a link twice if the carrier
> goes down followed by an admin down of the same link rendering multipath
> routes useless. This is similar to 79099aab38c8 for UNREGISTER events and
> DOWN events.
>
> Fix by tracking number of alive nexthops in mpls_ifdown similar to the
> logic in mpls_ifup. Checking the flags per nexthop once after all events
> have been processed is simpler than trying to maintian a running count
> through all event combinations.
>
> Also, WRITE_ONCE is used instead of ACCESS_ONCE to set rt_nhn_alive
> per a comment from checkpatch:
>     WARNING: Prefer WRITE_ONCE(<FOO>, <BAR>) over ACCESS_ONCE(<FOO>) = <BAR>
>
> Fixes: c89359a42e2a4 ("mpls: support for dead routes")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Acked-by: Robert Shearman <rshearma@brocade.com>
