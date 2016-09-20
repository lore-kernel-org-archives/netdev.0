From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UBSAN reports issue in ip_idents_reserve
Date: Tue, 20 Sep 2016 07:24:10 -0700
Message-ID: <1474381450.23058.13.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160920120000.GI1843@nanopsycho.orion>
         <1474378115.23058.2.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920133915.GJ1843@nanopsycho.orion>
         <1474380711.23058.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <1474381092.23058.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34124 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753586AbcITOYN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 10:24:13 -0400
Received: by mail-pa0-f42.google.com with SMTP id wk8so7643077pab.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 07:24:13 -0700 (PDT)
In-Reply-To: <1474381092.23058.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 07:18 -0700, Eric Dumazet wrote:

> +	 */
> +	if (unlikely(atomic_cmpxchg(p_id, old, new) != old))
> +		new = prandom_u32();
> +	return new;

Looks like we should return new - segs;
