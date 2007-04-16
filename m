From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP connection stops after high load.
Date: Mon, 16 Apr 2007 15:11:07 -0400
Message-ID: <4623CA4B.3000503@psc.edu>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>	 <20070412.141550.133265618.davem@davemloft.net>	 <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>	 <46224561.9010801@psc.edu>	 <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>	 <4623BB7B.3010705@psc.edu> <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com
To: Robert Iakobashvili <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:54966 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbXDPTLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 15:11:12 -0400
In-Reply-To: <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Iakobashvili wrote:
> Kernels 2.6.19 and 2.6.20 series are effectively broken right now.
> Don't you wish to patch them?
> 

I don't know if this qualifies as an unconditional bug.  The commit 
above was actually a bugfix so that the limits were not higher than 
total memory on some systems, but had the side effect that it made them 
even smaller on your particular configuration.  Also, having initial 
sysctl values that are conservatively small probably doesn't qualify as 
a bug (for patching stable trees).  You might ask the -stable 
maintainers if they have a different opinion.

For most people, 2.6.19 and 2.6.20 work fine.  For those who really care 
about the tcp_mem values (are using a substantial fraction of physical 
memory for TCP connections), the best bet is to set the tcp_mem sysctl 
values in the startup scripts, or use the new initialization function in 
2.6.21.

Thanks,
   -John
