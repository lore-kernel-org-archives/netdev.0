From: Nigel Kukard <nkukard@lbsd.net>
Subject: Re: [Bugme-new] [Bug 13561] New: swapper: page allocation failure.
 order:0, mode:0x20
Date: Wed, 17 Jun 2009 20:00:29 +0000
Message-ID: <4A394B5D.3070209@lbsd.net>
References: <bug-13561-10286@http.bugzilla.kernel.org/>	<20090617121610.d4f0ea9d.akpm@linux-foundation.org>	<4A394415.30004@lbsd.net> <20090617124620.44dd5ef0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from authsmtp-0-3.virt.iitsp.net ([66.197.161.151]:36458 "EHLO
	authsmtp-0-3.virt.iitsp.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbZFQUCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 16:02:30 -0400
In-Reply-To: <20090617124620.44dd5ef0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>   
>> maybe I"m mistaking the amount of RAM for the amount of memory in a
>> buffer used for network IO?
>>     
>
> [ 1884.639264] Node 0 DMA free:11692kB min:28kB low:32kB high:40kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:15284kB pages_scanned:0 all_unreclaimable? yes
>
> [ 1884.639271] Node 0 DMA32 free:5412kB min:6560kB low:8200kB high:9840kB active_anon:60476kB inactive_anon:12224kB active_file:28720kB inactive_file:2987624kB unevictable:0kB present:3333216kB pages_scanned:0 all_unreclaimable? no
>
> [ 1884.639279] Node 0 Normal free:444kB min:1524kB low:1904kB high:2284kB active_anon:12436kB inactive_anon:13984kB active_file:16356kB inactive_file:666568kB unevictable:480kB present:775680kB pages_scanned:0 all_unreclaimable? no
>
> Pretty much all your memory was used by pagecache.  The DMA32 zone is
> below the minimum threshold.  The VM has decided that there's no memory
> left for networking.  It has retained a little bit of free memory so
> the block device drivers can still perform writeout, to free up
> additional memory.
>
> What is _supposed_ to happen (and usually does) it that kswapd will see
> that the machine is getting short on memory and will work to free some
> up, thus making it available to networking receive.  But sometimes
> kswapd can't keep up.
>   
Understood .... I did copy about 2.5Tb of files from 1 SATA drive to
another and was busy trasferring 50Gb to the box from Gbit ethernet.

Cool, thanks again guys. Just thought I'd report to make sure its
something trivial and not a serious issue.  :)

-N
