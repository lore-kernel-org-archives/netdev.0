From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: contributions to iproute2
Date: Sat, 21 Mar 2015 08:25:37 +0200
Message-ID: <20150321062537.GA23505@angus-think.lan>
References: <ec4611159b474e158079d8d528e71030@BRMWP-EXMB11.corp.brocade.com>
 <20150320160819.1477223d@uryu.home.lan>
 <550CF00C.2090309@dogpad.tk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemming@brocade.com>
To: Joe Harvell <jharvell@dogpad.tk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:32795 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCUGhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 02:37:23 -0400
Received: by wgbcc7 with SMTP id cc7so105802001wgb.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 23:37:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <550CF00C.2090309@dogpad.tk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 11:14:04PM -0500, Joe Harvell wrote:
> Thanks, Stephen.
> 
> The bugfix is attached as fix-broken-get_prefix_1.diff with the following
> commit log:
> 
> commit 415464c94a62cfaa9c5ba493e45ce24a58d2118a
> Author: Joe Harvell <joe.harvell@tekcomms.com>
> Date:   Fri Mar 20 15:08:51 2015 -0500
> 
>      Fixing obvious error of passing in the wrong variable for the family
> parameter
>      of af_bit_len.
> 
> I assume master must have some new change because this fix was needed for a
> basic 'ip addr add 10.0.3.1/24 dev dumbo label foo' command I pased in.  In
> this case, 'family' passed into get_addr_1 two lines above is zero, causing
> get_addr_1 to detect the family from the address and populate the result in
> the family field in dst.  But then instead of passing in the result, family
> (still 0) is passed in to af_bit_len. Without my change, the above command
> complains that 10.0.3.1/24 is not an address prefix.  With the change it
> works fine as expected.
> 
Hi,

Thanks for catching it, this is a serious issue.

Does not the diff should be ?

-               dst->bitlen = af_bit_len(family);
+               dst->bitlen = af_bit_len(dst->family);

Also you can use 'git send-email' to send separate patchs as email,
instead of attaching them.

Regards,
