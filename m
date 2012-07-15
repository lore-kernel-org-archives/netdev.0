From: Marc MERLIN <marc@merlins.org>
Subject: Re: 3.4.4/amd64 full interrupt hangs under big nfs copies
Date: Sun, 15 Jul 2012 14:59:35 -0700
Message-ID: <20120715215935.GF24420@merlins.org>
References: <20120409.143710.879746943062854492.davem@davemloft.net> <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop> <20120409.153452.1284163346306246866.davem@davemloft.net> <1334030180.13293.98.camel@edumazet-glaptop> <20120410051127.GA32048@merlins.org> <1334038263.2907.1.camel@edumazet-glaptop> <20120411052733.GA17352@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Larry.Finger@lwfinger.net,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magic.merlins.org ([209.81.13.136]:40422 "EHLO
	mail1.merlins.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab2GOV7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2012 17:59:40 -0400
Content-Disposition: inline
In-Reply-To: <20120411052733.GA17352@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 10:27:33PM -0700, Marc MERLIN wrote:
> On Tue, Apr 10, 2012 at 08:11:03AM +0200, Eric Dumazet wrote:
> > Please try following patch, as it solved the problem for me (no more
> > order-1 allocations in tx path)
> 
> I applied our patch to 3.3.1 and cannot reproduce the problem anymore.
> 
> I'll leave a big wireless copy running overnight just in case, but I think
> you fixed it.

Mmmh, so I'm running 3.4.4 and I had another full machine hang while copying
big files (gigabytes) over wireless via NFS.
The laptop self recovered after 5mn or so (mouse cursor would not even
move) and I was able to kill -9 the process (midnight commander).
mc did not actually stop for another 4mn or so (i.e. it took that long for
the process to come out of kernel hung state), but the machine was usable
during that time.
Note that copying the same data with scp works fine.
NFS mount looks like this:
gargamel:/mnt/dshelf2/ /net/gargamel/mnt/dshelf2 nfs4 rw,nosuid,nodev,relatime,vers=4.0,rsize=524288,wsize=524288,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=192.168.205.7,local_lock=none,addr=192.168.205.3 0 0

I didn't have anything like last time in the kernel logs, and more
annoyingly, ps -elf does not show anything for any process in WCHAN,
making pointing the finger a bit harder (procps-ng 3.3.3 does not show
anything other than '-' in WCHAN for any process with 3.4.4).

My understanding is that user space calling drivers that shut off all
interrupts for extended periods of time (as least I think so since my mouse
cursor would not move), is still a kernel bug.

For what it's worth, copying 1GB of data in lots of small files does not
cause problems, it seems that it's big files that cause a problem since they
likely fill a buffer somewhere while interrupts are disabled.

Do you have an idea of how I can find out where my mc process is stuck in
the kernel?
Should I reproduce with specific sysrq output?

Thanks,
Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/  
