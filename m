From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [v2] act_mirred: Fix bogus header when redirecting from VLAN
Date: Fri, 17 Apr 2015 08:26:52 -0700
Message-ID: <20150417152651.GA6965@Alexeis-MBP.westell.com>
References: <20150417010216.GA22415@gondor.apana.org.au>
 <20150417013401.GA4335@Alexeis-MacBook-Pro.local>
 <20150417021501.GB22835@gondor.apana.org.au>
 <20150417024029.GA6718@Alexeis-MacBook-Pro.local>
 <20150417053209.GA23855@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:33865 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbbDQP0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 11:26:54 -0400
Received: by iedfl3 with SMTP id fl3so84349259ied.1
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 08:26:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150417053209.GA23855@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 01:32:09PM +0800, Herbert Xu wrote:
> When you redirect a VLAN device to any device, you end up with
> crap in af_packet on the xmit path because hard_header_len is
> not equal to skb->mac_len.  So the redirected packet contains
> four extra bytes at the start which then gets interpreted as
> part of the MAC address.
> 
> This patch fixes this by only pushing skb->mac_len.  We also
> need to fix ifb because it tries to undo the pushing done by
> act_mirred.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
