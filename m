From: Christian Schmid <webmaster@rapidforum.com>
Subject: Re: argh more bugs!!!
Date: Tue, 22 Feb 2005 01:37:46 +0100
Message-ID: <421A7EDA.4090205@rapidforum.com>
References: <421A3EB8.4050607@rapidforum.com> <20050221202854.GA26248@electric-eye.fr.zoreil.com> <421A45CA.80001@rapidforum.com> <20050221205606.GB26248@electric-eye.fr.zoreil.com> <421A4FFA.7090003@rapidforum.com> <20050221213610.GC26248@electric-eye.fr.zoreil.com> <421A68D5.6020808@rapidforum.com> <20050222002315.GE26248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050222002315.GE26248@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK the problem with the break is solved. I am REALLY sorry but it was not the net-code in linux. The 
SQL-Server has experienced an index-key collision as I added a second multi-key to it. It seems the 
sort-buffer overflowed and it suddenly raised the cpu-time very high. I will contact 
mysql-developers and ask them about it. The break was due to the table-lock mysql does for every update.

The problem with the slowdown at many sockets still exists. This isnt solved yet. I hope this isnt 
my fault as well. Else I feel forced to spend 1000 dollars to some open-source foundation. *grin*

Francois Romieu wrote:
> Christian Schmid <webmaster@rapidforum.com> :
> 
>>It suddenly appeared again. there you go..........
> 
> 
> Thanks. I'll do some graphics tomorrow to be sure but the slabs do not seem
> wrong. vmstat output looks weird:
> 
> procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa
>  2  3      0   8496  25236 7941848    0    0 37920     0 7563  2788 13 19 34 33
>  2  2      0   9268  25172 7941300    0    0 36688     0 7424  2814 15 19 40 26
>  1  0      0  19576  25264 7928356    0    0  9468 13080 8072   607 22 13 59  6
>  1  0      0  18052  25264 7928356    0    0     0     0 7975    40 18  7 75  0
>  1  0      0  17660  25264 7928356    0    0     0     0 7487    38 21  4 75  0
>  1  0      0  18560  25264 7928356    0    0     0     0 6500    44 22  3 75  0
>  1  0      0  20072  25264 7928356    0    0     0     0 5834    44 23  2 75  0
>  1  3      0  21516  25320 7928300    0    0     0  3408 6796   153 24  3 58 15
>  0  4      0  10596  25436 7942056    0    0 44084  2220 11226  4282 12 10 31 47
>  2  2      0   9324  25240 7943952    0    0 39292     0 8433  3212  9 13 39 38
>  4  1      0  11596  25300 7941580    0    0 35820     0 7945  4306 17 21 30 32
>  0  5      0  13208  25560 7939280    0    0 40684  6456 7920  4081 19 18 32 31
>  4  1      0  12620  24944 7859724    0    0 32204   272 7306  2304 12 28 27 34
>  1  3      0  64964  24852 7888240    0    0 44944    96 7314  2631 19 31 24 27
> 
> ???
> 
> Since you have a lot of cpu, could you "strace -f -T -o /tmp/nitz -p xyz" one
> or two of your perl processes when they hang ?
> 
> If you do not have too many processes, monitoring "echo t > /proc/sysrq-trigger"
> for some time could tell what the system is waiting for.
> 
> --
> Ueimor
> 
> 
