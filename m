From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [RFC PATCH net-next 4/4 V4] try to fix performance regression
Date: Wed, 12 Dec 2012 08:25:23 -0800
Message-ID: <1355329523.9139.578.camel@edumazet-glaptop>
References: <20121210.160230.1883556145617090938.davem@davemloft.net>
	 <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brutus@google.com, netdev@vger.kernel.org
To: Weiping Pan <wpan@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54144 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab2LLQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 11:25:28 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so718978pbc.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 08:25:28 -0800 (PST)
In-Reply-To: <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-12 at 22:29 +0800, Weiping Pan wrote:

> 
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

I cant reproduce your strange numbers here, they make no sense to me.

for s in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768
65536 131072 262144 524288 1048576
do
 ./netperf -- -m $s -M $s | tail -n1
done

Results :

87380  16384      1    10.00      34.68   
 87380  16384      2    10.00      68.07   
 87380  16384      4    10.00     126.27   
 87380  16384      8    10.00     284.50   
 87380  16384     16    10.00     574.38   
 87380  16384     32    10.00    1091.74   
 87380  16384     64    10.00    2130.23   
 87380  16384    128    10.00    4001.83   
 87380  16384    256    10.00    7666.01   
 87380  16384    512    10.00    13425.81   
 87380  16384   1024    10.00    21146.43   
 87380  16384   2048    10.00    28551.42   
 87380  16384   4096    10.00    37878.95   
 87380  16384   8192    10.00    42507.23   
 87380  16384  16384    10.00    46782.53   
 87380  16384  32768    10.00    42410.97   
 87380  16384  65536    10.00    43053.09   
 87380  16384 131072    10.00    44504.20   
 87380  16384 262144    10.00    50211.74   
 87380  16384 524288    10.00    54004.23   
 87380  16384 1048576    10.00    53852.26   
