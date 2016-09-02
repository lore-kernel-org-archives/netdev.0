From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] net: Don't delete routes in different VRFs
Date: Fri, 2 Sep 2016 10:08:43 -0600
Message-ID: <5d78e432-bd81-ce0b-c311-3170b17868d9@cumulusnetworks.com>
References: <20160902052607.9303-1-mark.tomlinson@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33569 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932338AbcIBQIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:08:46 -0400
Received: by mail-pa0-f43.google.com with SMTP id cy9so41677264pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 09:08:46 -0700 (PDT)
In-Reply-To: <20160902052607.9303-1-mark.tomlinson@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/1/16 11:26 PM, Mark Tomlinson wrote:
> When deleting an IP address from an interface, there is a clean-up of
> routes which refer to this local address. However, there was no check to
> see that the VRF matched. This meant that deletion wasn't confined to
> the VRF it should have been.
> 
> To solve this, a new field has been added to fib_info to hold a table
> id. When removing fib entries corresponding to a local ip address, this
> table id is also used in the comparison.
> 
> The table id is populated when the fib_info is created. This was already
> done in some places, but not in ip_rt_ioctl(). This has now been fixed.
> 

The best fixes tag is:
Fixes: 021dd3b8a142 ("net: Add routes to the table associated with the device")

> Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
> ---
>  include/net/ip_fib.h     | 3 ++-
>  net/ipv4/fib_frontend.c  | 3 ++-
>  net/ipv4/fib_semantics.c | 8 ++++++--
>  3 files changed, 10 insertions(+), 4 deletions(-)

Acked-by: David Ahern <dsa@cumulusnetworks.com>
Tested-by: David Ahern <dsa@cumulusnetworks.com>

Mark: send a v2 with the Fixes tag and my acked-by and tested-by.

Thanks for the patch.
