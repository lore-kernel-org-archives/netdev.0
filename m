From: roopa <roopa@cumulusnetworks.com>
Subject: Re: af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 04 Aug 2015 06:39:09 -0700
Message-ID: <55C0C07D.2050505@cumulusnetworks.com>
References: <20150804074402.GA10867@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32823 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933124AbbHDNjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 09:39:11 -0400
Received: by padck2 with SMTP id ck2so9108669pad.0
        for <netdev@vger.kernel.org>; Tue, 04 Aug 2015 06:39:10 -0700 (PDT)
In-Reply-To: <20150804074402.GA10867@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/4/15, 12:44 AM, Dan Carpenter wrote:
> Hello Roopa,
>
> I have a concern about patch bf21563acc1d: "af_mpls: fix undefined
> reference to ip6_route_output" from Jul 30, 2015.
>
> net/mpls/af_mpls.c
>     450
>     451          dev = find_outdev(net, cfg);
>     452          if (IS_ERR(dev)) {
>
> find_outdev() used to return NULL pointers but now it only returns NULL
> if cfg->rc_via_table == NEIGH_LINK_TABLE or dev_get_by_index() fails.
> I think it could lead to a NULL dereference and we don't check for that
> here.
>
> Returning a mix of error pointers and NULL is bad style, it needs a big
> comment at the top of the function if it's deliberate.
>
>     453                  err = PTR_ERR(dev);
>     454                  dev = NULL;
>     455                  goto errout;
>     456          }
>
>
You are right. The cfg->rc_via_table == NEIGH_LINK_TABLE or 
dev_get_by_index() case, needs a ERR_PTR(-ENODEV).
I will get a patch out shortly.

thanks. I just submitted a patch.
