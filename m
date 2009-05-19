From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fw: [Bug 13339] New: rtable leak in ipv4/route.c
Date: Tue, 19 May 2009 12:34:17 +0000
Message-ID: <20090519123417.GA7376@ff.dom.local>
References: <20090518193559.05295fe4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: lav@yar.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:2112 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbZESMe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 08:34:26 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1832757rvb.1
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 05:34:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090518193559.05295fe4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19-05-2009 04:35, Stephen Hemminger wrote:
> 
> Begin forwarded message:
> 
> Date: Mon, 18 May 2009 14:10:20 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 13339] New: rtable leak in ipv4/route.c
> 
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=13339
...
> 2.6.29 patch has introduced flexible route cache rebuilding. Unfortunately the
> patch has at least one critical flaw, and another problem.
> 
> rt_intern_hash calculates rthi pointer, which is later used for new entry
> insertion. The same loop calculates cand pointer which is used to clean the
> list. If the pointers are the same, rtable leak occurs, as first the cand is
> removed then the new entry is appended to it.
> 
> This leak leads to unregister_netdevice problem (usage count > 0).
> 
> Another problem of the patch is that it tries to insert the entries in certain
> order, to facilitate counting of entries distinct by all but QoS parameters.
> Unfortunately, referencing an existing rtable entry moves it to list beginning,
> to speed up further lookups, so the carefully built order is destroyed.
> 
> For the first problem the simplest patch it to set rthi=0 when rthi==cand, but
> it will also destroy the ordering.

I think fixing this bug fast is more important than this
ordering or counting. Could you send your patch proposal?

Thanks,
Jarek P.

