From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 4/4 V4] try to fix performance regression
Date: Wed, 12 Dec 2012 14:57:56 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70ED@saturn3.aculab.com>
References: <117a10f9575d95d6a9ea4602ea7376e2b6d5ccd1.1355320533.git.wpan@redhat.com> <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <brutus@google.com>, <netdev@vger.kernel.org>
To: "Weiping Pan" <wpan@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:46975 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752041Ab2LLO7Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 09:59:24 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11690-05 for <netdev@vger.kernel.org>;
 Wed, 12 Dec 2012 14:59:20 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>         MS       BASE    AF_UNIX    FRIENDS            TCP_STREAM_MS
>          1      10.70       5.40       4.02   37%   74%
>          2      28.01       9.67       7.97   28%   82%
>          4      55.53      19.78      16.48   29%   83%
>          8     115.40      38.22      33.51   29%   87%
>         16     227.31      81.06      67.70   29%   83%
>         32     446.20     166.59     129.31   28%   77%
>         64     849.04     336.77     259.43   30%   77%
>        128    1440.50     661.88     530.43   36%   80%
>        256    2404.70    1279.67    1029.15   42%   80%
>        512    4331.53    2501.30    1942.21   44%   77%
>       1024    6819.78    4622.37    4128.10   60%   89%
>       2048   10544.60    6348.81    6349.59   60%  100%
>       4096   12830.41    8324.43    7984.43   62%   95%
>       8192   13462.65    8355.49   11079.37   82%  132%
>      16384    9960.87   10840.13   13037.81  130%  120%
>      32768    8749.31   11372.15   15087.08  172%  132%
>      65536    7580.27   12150.23   14971.42  197%  123%
>     131072    6727.74   11451.34   13604.78  202%  118%
>     262144    7673.14   11613.10   11436.97  149%   98%
>     524288    7366.17   11675.95   11559.43  156%   99%
>    1048576    6608.57   11883.01   10103.20  152%   85%
> MS means Message Size in bytes, that is -m -M for netperf

If I read that table correctly, it seems to imply that
something goes badly wrong for 'normal' TCP loopback
connections when the read/write size exceeds 8k.
Putting effort into fixing that would appear to be
more worthwhile than the 'friends' code.

	David
