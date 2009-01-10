From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: Some NIPQUAD_FMT -> %pI4 conversions are broken
Date: Fri, 09 Jan 2009 22:07:25 -0800
Message-ID: <1231567645.5714.19.camel@brick>
References: <adaprivom8o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:32655 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbZAJGH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 01:07:28 -0500
Received: by wf-out-1314.google.com with SMTP id 27so10230185wfd.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 22:07:27 -0800 (PST)
In-Reply-To: <adaprivom8o.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-09 at 19:47 -0800, Roland Dreier wrote:
> I just noticed (by getting a messed up print in my kernel log) that most
> of the changes to drivers/infiniband/hw/nes in commit 63779436
> ("drivers: replace NIPQUAD()") were wrong: the idea was to change printk
> statements like
> 
> 	printk("..." NIPQUAD_FMT "...", NIPQUAD(foo));
> 
> but most of the changes in nes were to code like
> 
> 	printk("..." NIPQUAD_FMT "...", HIPQUAD(foo));
> 
> ie *H* IPQUAD not *N* IPQUAD, indicating the foo is in host endian
> order, and hence the new code
> 
> 	printk("...%pI4...", &foo);
> 
> prints the IP in reverse order now.
> 
> I don't see a good way to fix this without introducing a temporary
> variable to hold a swapped IP address... but is there a better way?
> 

My apologies indeed, the best choice I think is to add a temp var for
now and I'll work with you to eliminate the byteswapping further up the
callchain so a be32 gets passed down, but that might be too involved for 2.6.29.

Sound OK?

Harvey

