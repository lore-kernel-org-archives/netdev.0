From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] mpls: Do not decrement alive counter for unregister
 events
Date: Mon, 13 Mar 2017 15:11:06 -0600
Message-ID: <cd885b2c-15f3-6f72-6fa9-aaabaea58ccd@cumulusnetworks.com>
References: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
 <342ff118-9d48-e974-98e0-0789f6efb4f3@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36424 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdCMVLJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 17:11:09 -0400
Received: by mail-pg0-f43.google.com with SMTP id g2so52845643pge.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 14:11:08 -0700 (PDT)
In-Reply-To: <342ff118-9d48-e974-98e0-0789f6efb4f3@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 5:10 AM, Robert Shearman wrote:
> Doesn't this leave the problem that if the device's link goes down and
> then the device gets deleted the alive count will be decremented twice
> for the same path?

yes. and it exposes another bug in multipath selection.

> 
> Perhaps it would be better to change the condition for decrementing the
> alive count to be "!(nh->nh_flags & (RTNH_F_LINKDOWN | RTNH_F_DEAD))"?

or maybe the logic in mpls_ifup is the way to go -- reset the alive
counter based on the sum of each nexhop's status.

I'll send more patches soon.
