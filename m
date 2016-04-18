From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poorer networking performance in later kernels?
Date: Mon, 18 Apr 2016 05:16:54 -0700
Message-ID: <1460981814.10638.104.camel@edumazet-glaptop3.roam.corp.google.com>
References: <SN1PR0301MB19987565B71A4688593A2CDBD6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
	 <SN1PR0301MB19983946D7A38001E4B54D20D6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
	 <1460759582.10638.79.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Butler, Peter" <pbutler@sonusnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35319 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbcDRMQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 08:16:57 -0400
Received: by mail-pf0-f172.google.com with SMTP id n1so80564505pfn.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 05:16:56 -0700 (PDT)
In-Reply-To: <1460759582.10638.79.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-15 at 15:33 -0700, Eric Dumazet wrote:
> On Fri, 2016-04-15 at 21:02 +0000, Butler, Peter wrote:
> > (Please keep me CC'd to all comments/responses)
> > 
> > I've tried a kernel upgrade from 3.4.2 to 4.4.0 and see a marked drop in networking performance.  Nothing was changed on the test systems, other than the kernel itself (and kernel modules).  The identical .config used to build the 3.4.2 kernel was brought over into the 4.4.0 kernel source tree, and any configuration differences (e.g. new parameters, etc.) were taken as default values.
> > 
> > The testing was performed on the same actual hardware for both kernel versions (i.e. take the existing 3.4.2 physical setup, simply boot into the (new) kernel and run the same test).  The netperf utility was used for benchmarking and the testing was always performed on idle systems.
> > 
> > TCP testing yielded the following results, where the 4.4.0 kernel only got about 1/2 of the throughput:
> > 
> >       Recv     Send       Send                          Utilization       Service Demand
> >       Socket   Socket     Message Elapsed               Send     Recv     Send    Recv
> >       Size     Size       Size    Time       Throughput local    remote   local   remote
> >       bytes    bytes      bytes   secs.      10^6bits/s % S      % S      us/KB   us/KB
> > 
> > 3.4.2 13631488 13631488   8952    30.01      9370.29    10.14    6.50     0.709   0.454
> > 4.4.0 13631488 13631488   8952    30.02      5314.03    9.14     14.31    1.127   1.765
> > 
> > SCTP testing yielded the following results, where the 4.4.0 kernel only got about 1/3 of the throughput:
> > 
> >       Recv     Send       Send                          Utilization       Service Demand
> >       Socket   Socket     Message Elapsed               Send     Recv     Send    Recv
> >       Size     Size       Size    Time       Throughput local    remote   local   remote
> >       bytes    bytes      bytes   secs.      10^6bits/s  % S     % S      us/KB   us/KB
> > 
> > 3.4.2 13631488 13631488   8952    30.00      2306.22    13.87    13.19    3.941   3.747
> > 4.4.0 13631488 13631488   8952    30.01       882.74    16.86    19.14    12.516  14.210
> > 
> > The same tests were performed a multitude of time, and are always consistent (within a few percent).  I've also tried playing with various run-time kernel parameters (/proc/sys/kernel/net/...) on the 4.4.0 kernel to alleviate the issue but have had no success at all.
> > 
> > I'm at a loss as to what could possibly account for such a discrepancy...
> 
> Maybe new kernel is faster and you have drops somewhere ?
> 
> nstat >/dev/null
> netperf -H ...
> nstat
> 
> Would help
> 

Are you receiving my mails, or simply ignoring them ?

Thanks.
