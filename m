From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/4] net: mpls: Allow users to configure more
 labels per route
Date: Wed, 29 Mar 2017 15:20:07 -0600
Message-ID: <3c0e86a9-1065-87ac-fea4-87918599a8a7@cumulusnetworks.com>
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
Received: from mail-pg0-f44.google.com ([74.125.83.44]:36630 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932822AbdC2VUK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 17:20:10 -0400
Received: by mail-pg0-f44.google.com with SMTP id g2so18434555pge.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 14:20:09 -0700 (PDT)
In-Reply-To: <871stiayie.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/27/17 9:08 PM, Eric W. Biederman wrote:
> I believe we should just kill MAX_NEW_LABELS.
> 
> I think the only significant change from your patch is the removal of an
> array from mpls_route_config.
> 
> With the removal of MAX_NEW_LABELS I would replace it by a sanity check
> in mpls_rt_alloc that verifies that the amount we are going to allocate
> for struct mpls_route is < PAGE_SIZE.  Anything larger is just
> asking for trouble.
> 
> That should put our practical limit just a little bit below 32 nexthops
> adding 32 labels each.

The 4096 limit works nice for mpls_route but not for lwt encap info.
That struct is 4-bytes + the labels. Seems odd to let ip->mpls allow up
to 255 labels (max for u8) while mpls->mpls has a limit.

I'm going to send v2 soon with the 4096 limit for mpls_route total size
but keeping the MAX_NEW_LABELS with a count of 30 for both. That keeps
the two paths consistent, keeps mpls_iptunnel_encap < 128 bytes for the
max allocation and 30 labels is allows plenty of options for TE and SR.
