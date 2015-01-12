From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: cleanup bond_opts array
Date: Mon, 12 Jan 2015 16:43:32 -0500 (EST)
Message-ID: <20150112.164332.714842849672498427.davem@davemloft.net>
References: <1420828268-10360-1-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@redhat.com
To: jtoppins@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54306 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152AbbALVne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:43:34 -0500
In-Reply-To: <1420828268-10360-1-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Date: Fri,  9 Jan 2015 13:31:08 -0500

> Remove the empty array element initializer and size the array with
> BOND_OPT_LAST so the compiler will complain if more elements are in
> there than should be.
> 
> An interesting unwanted side effect of this initializer is that if one
> inserts new options into the middle of the array then this initializer
> will zero out the option that equals BOND_OPT_TLB_DYNAMIC_LB+1.
> 
> Example:
> Extend the OPTS enum:
> enum {
>    ...
>    BOND_OPT_TLB_DYNAMIC_LB,
>    BOND_OPT_LACP_NEW1,
>    BOND_OPT_LAST
> };
> 
> Now insert into bond_opts array:
> static const struct bond_option bond_opts[] = {
>       ...
>       [BOND_OPT_LACP_RATE] = { .... unchanged stuff .... },
>       [BOND_OPT_LACP_NEW1] = { ... new stuff ... },
>       ...
>       [BOND_OPT_TLB_DYNAMIC_LB] = { .... unchanged stuff ....},
>       { } // MARK A
> };
> 
> Since BOND_OPT_LACP_NEW1 = BOND_OPT_TLB_DYNAMIC_LB+1, the last
> initializer (MARK A) will overwrite the contents of BOND_OPT_LACP_NEW1
> and can be easily viewed with the crash utility.
> 
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>

Applied.
