From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: route: fix multicast route dumps
Date: Thu, 1 Sep 2016 09:07:19 -0700
Message-ID: <20160901090719.7c763916@xeon-e3>
References: <1471697590-24466-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
        roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34399 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934106AbcIAQHX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 12:07:23 -0400
Received: by mail-pf0-f180.google.com with SMTP id p64so32756301pfb.1
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 09:07:08 -0700 (PDT)
In-Reply-To: <1471697590-24466-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Aug 2016 14:53:10 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> If we have multicast routes and do ip route show table all we'll get the
> following output:
>  ...
>  multicast ???/32 from ???/32  table default  proto static  iif eth0
> The "???" are because the rtm_family is set to RTNL_FAMILY_IPMR instead
> (or RTNL_FAMILY_IP6MR for ipv6). Add a simple workaround that returns the
> real family based on the rtm_type (always RTN_MULTICAST for ipmr routes)
> and the rtm_family. Similar workaround is already used in ipmroute, and
> we can use this helper there as well.
> 
> After the patch the output is:
> multicast 239.10.10.10/32 from 0.0.0.0/32  table default  proto static  iif eth0
> 
> Also fix a minor whitespace error and switch to tabs.
> 
> Reported-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This makes sense, applied it.
Hope no one was actually depending on the ??? output.
