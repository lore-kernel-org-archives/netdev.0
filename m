From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: Use passed in table for nexthop
 lookups
Date: Wed, 13 Apr 2016 22:07:28 -0600
Message-ID: <570F1780.20606@cumulusnetworks.com>
References: <1460052674-1204-1-git-send-email-dsa@cumulusnetworks.com>
 <20160413.214151.2294488534397440295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37267 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbcDNEHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 00:07:31 -0400
Received: by mail-ig0-f171.google.com with SMTP id g8so79935447igr.0
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 21:07:31 -0700 (PDT)
In-Reply-To: <20160413.214151.2294488534397440295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/16 7:41 PM, David Miller wrote:
> This is semantically different from the referenced ipv4 change.
>
> Lack of a matching table for cfg->fc_table does not result in a
> failure on the ipv4 side.  It falls back in that case.
>
> But here in this ipv6 patch, you do fail if fib6_get_table() gives
> NULL.

Unintentional. I meant for this to behave exactly like the ipv4 change.

>
> One thing that drives me absolutely crazy is all of the subtle
> semantic differences between our ipv4 and ipv6 stack, so I refuse to
> knowingly add new such cases.

I feel that pain on a daily basis.

>
> Therefore, please make the ipv6 behavior match exactly what ipv4
> does.

Will remove the goto out on the table lookup fail and have it fallback 
to current logic. Thanks for catching that difference.
