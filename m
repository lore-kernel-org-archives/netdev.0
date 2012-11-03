From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next:master 122/152] drivers/ptp/ptp_chardev.c:36
 ptp_ioctl() warn: 'sysoff' puts 832 bytes on stack
Date: Sat, 3 Nov 2012 05:53:39 +0100
Message-ID: <20121103045339.GA2277@netboy.at.omicron.at>
References: <509326ff.Rs30l/1GTlOl9dW+%yuanhan.liu@linux.intel.com>
 <20121102020631.GI16883@yliu-dev.sh.intel.com>
 <20121102085915.GC2486@netboy.at.omicron.at>
 <20121102.213928.934210347094361569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yuanhan.liu@linux.intel.com, changlongx.xie@intel.com,
	fengguang.wu@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63148 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab2KCExt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 00:53:49 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2104089eek.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 21:53:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20121102.213928.934210347094361569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 02, 2012 at 09:39:28PM -0400, David Miller wrote:
> > I am aware that these methods use large stack buffers, but I thought
> > it was okay seeing as they are both under the 1k limit.
> 
> I think you should avoid such a local stack variable here.
> 
> It's not that big of a deal to use kmalloc or whatever so just
> do that and add the necessary kfree cleanups et al.

The usage pattern will be that the user calls these again and
again. For the sysoff it will be at least once every second, and for
the events it could be ASAP in a tight loop.

Isn't it being nicer to the memory allocation code not to repeatedly
request small chunks?

Thanks,
Richard
