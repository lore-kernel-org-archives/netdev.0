From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: TCP connection stops after high load.
Date: Mon, 16 Apr 2007 20:51:54 +0200
Message-ID: <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>
References: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>
	 <20070412.141550.133265618.davem@davemloft.net>
	 <7e63f56c0704150514q3b1271e8lcc9e8f30387d7540@mail.gmail.com>
	 <46224561.9010801@psc.edu>
	 <7e63f56c0704150849r5b019962v296b4266021a6fe1@mail.gmail.com>
	 <4623BB7B.3010705@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	greearb@candelatech.com
To: "John Heffner" <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:8220 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213AbXDPSv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 14:51:56 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1190434uga
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2007 11:51:54 -0700 (PDT)
In-Reply-To: <4623BB7B.3010705@psc.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> Robert Iakobashvili wrote:
> >> > Vanilla 2.6.18.3 works for me perfectly, whereas 2.6.19.5 and
> >> > 2.6.20.6 do not.
> >> >
> >> > Looking into the tcp /proc entries of 2.6.18.3 versus 2.6.19.5
> >> > tcp_rmem and tcp_wmem are the same, whereas tcp_mem are
> >> > much different:
> >> >
> >> > kernel                  tcp_mem
> >> > ---------------------------------------
> >> > 2.6.18.3    12288 16384 24576
> >> > 2.6.19.5      3072    4096   6144
> >
> >> Another patch that went in right around that time:
> >>
> >> commit 52bf376c63eebe72e862a1a6e713976b038c3f50
> >> Author: John Heffner <jheffner@psc.edu>
> >> Date:   Tue Nov 14 20:25:17 2006 -0800
> >>
> >>      [TCP]: Fix up sysctl_tcp_mem initialization.
> >> (This has been changed again for 2.6.21.)
> >>

> Yes, this difference is caused by the commit above.
> The current net-2.6 (2.6.21) has a redesigned tcp_mem initialization
> that should give you more appropriate values, something like 45408 60546
> 90816.  For reference:
> Commit: 53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
> Author: John Heffner <jheffner@psc.edu> Fri, 16 Mar 2007 15:04:03 -0700
>
>      [TCP]: Fix tcp_mem[] initialization.
>      Change tcp_mem initialization function.  The fraction of total memory
>      is now a continuous function of memory size, and independent of page
>      size.


Kernels 2.6.19 and 2.6.20 series are effectively broken right now.
Don't you wish to patch them?

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://curl-loader.sourceforge.net
An open-source HTTP/S, FTP/S traffic
generating, and web testing tool.
