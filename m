From: Weiping Pan <wpan@redhat.com>
Subject: Re: [RFC PATCH net-next 4/4 V4] try to fix performance regression
Date: Thu, 13 Dec 2012 22:05:20 +0800
Message-ID: <50C9E0A0.2040409@redhat.com>
References: <117a10f9575d95d6a9ea4602ea7376e2b6d5ccd1.1355320533.git.wpan@redhat.com> <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com> <AE90C24D6B3A694183C094C60CF0A2F6026B70ED@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, brutus@google.com, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756283Ab2LMOF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2012 09:05:27 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70ED@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2012 10:57 PM, David Laight wrote:
>>          MS       BASE    AF_UNIX    FRIENDS            TCP_STREAM_MS
>>           1      10.70       5.40       4.02   37%   74%
>>           2      28.01       9.67       7.97   28%   82%
>>           4      55.53      19.78      16.48   29%   83%
>>           8     115.40      38.22      33.51   29%   87%
>>          16     227.31      81.06      67.70   29%   83%
>>          32     446.20     166.59     129.31   28%   77%
>>          64     849.04     336.77     259.43   30%   77%
>>         128    1440.50     661.88     530.43   36%   80%
>>         256    2404.70    1279.67    1029.15   42%   80%
>>         512    4331.53    2501.30    1942.21   44%   77%
>>        1024    6819.78    4622.37    4128.10   60%   89%
>>        2048   10544.60    6348.81    6349.59   60%  100%
>>        4096   12830.41    8324.43    7984.43   62%   95%
>>        8192   13462.65    8355.49   11079.37   82%  132%
>>       16384    9960.87   10840.13   13037.81  130%  120%
>>       32768    8749.31   11372.15   15087.08  172%  132%
>>       65536    7580.27   12150.23   14971.42  197%  123%
>>      131072    6727.74   11451.34   13604.78  202%  118%
>>      262144    7673.14   11613.10   11436.97  149%   98%
>>      524288    7366.17   11675.95   11559.43  156%   99%
>>     1048576    6608.57   11883.01   10103.20  152%   85%
>> MS means Message Size in bytes, that is -m -M for netperf
> If I read that table correctly, it seems to imply that
> something goes badly wrong for 'normal' TCP loopback
> connections when the read/write size exceeds 8k.
> Putting effort into fixing that would appear to be
> more worthwhile than the 'friends' code.
>
> 	David
>
Hi, David,

In my test program, I run normal tcp loopback then friends for each 
message size,
then it generates such strange numbers.

But if I just run normal tcp loopback for each message size, then the 
performance is stable.
[root@intel-s3e3432-01 ~]# cat base.sh
for s in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 
65536 131072 262144 524288 1048576
do
netperf -i -2,10 -I 95,20 -- -m $s -M $s | tail -n1
done


  87380  16384      1    10.09      15.51
  87380  16384      2    10.01      31.39
  87380  16384      4    10.00      55.78
  87380  16384      8    10.00     115.17
  87380  16384     16    10.00     231.66
  87380  16384     32    10.00     452.42
  87380  16384     64    10.00     859.92
  87380  16384    128    10.00    1464.91
  87380  16384    256    10.00    2613.12
  87380  16384    512    10.00    4338.88
  87380  16384   1024    10.00    7174.22
  87380  16384   2048    10.00    10452.84
  87380  16384   4096    10.00    11932.33
  87380  16384   8192    10.00    13750.49
  87380  16384  16384    10.00    13196.98
  87380  16384  32768    10.00    14881.25
  87380  16384  65536    10.00    13685.36
  87380  16384 131072    10.00    16088.71
  87380  16384 262144    10.00    17193.86
  87380  16384 524288    10.00    16696.07
  87380  16384 1048576    10.00    13638.13

thanks
Weiping Pan
