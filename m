From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [ANNOUNCE] iproute2-2.6.11-050314
Date: Tue, 15 Mar 2005 10:41:08 +0100
Message-ID: <4236ADB4.6000600@cosmosbay.com>
References: <20050314163438.1f73ec6d@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050314163438.1f73ec6d@dxpl.pdx.osdl.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> New version of Iproute2 is available:
> 
> http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.11-050314.tar.gz
> 

Hi

It seems rtstat has a problem, at least on my dual cpu (x86) machine :

The 'entries' column seems ok, not the following ones (rt_cache in_hit, 
rt_cache in_slow_tot)

It seems only the last line from /proc/net/stat/rt_cache is taken into 
account, instead of summing all the lines (one line per cpu)

(only the first column 'entries' is not to be summed)

[root@ns2513 linux-2.6.11]# /usr/src/iproute2-2.6.11/misc/rtstat -c 3 -i 5
rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
  entries|  in_hit|in_slow_|in_no_ro|  in_brd|in_marti|in_marti| 
out_hit|out_slow|out_slow|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|out_hlis|
         |        |     tot|     ute|        |  an_dst|  an_src| 
|    _tot|     _mc|        |      ed|    miss| verflow| _search|t_search|
   128497|       0|       0|       0|       0|       0|       0| 
0| 3704216|15597939|       0|15597874|15595738|     676|       0|       0|
   129505|       0|       0|       0|       0|       0|       0| 
0|      13|      70|       0|      70|      70|       0|       0|       0|
   129147|       0|       0|       0|       0|       0|       0| 
0|       2|      19|       0|      19|      19|       0|       0|       0|





[root@ns2513 linux-2.6.11]# cat /proc/net/stat/rt_cache ; sleep 3 ; cat 
/proc/net/stat/rt_cache
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst 
in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored 
gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search
0001d4c1  6928f9bd 87a34938 00000000 00000000 00004c28 00000000 0000103b 
  0e15593e 2f5295f0 00000000 b6e7adb3 b6d110f6 0004cbe2 00000000 
df1dd7b9 40ef942d
0001d4c1  00000000 00000000 00000000 00000000 00000000 00000000 00000000 
  011a9c85 04a60a1b 00000000 04a608d8 04a5df1f 00000d35 00000000 
00000000 1d94490b
entries  in_hit in_slow_tot in_no_route in_brd in_martian_dst 
in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored 
gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search
0001ea38  692916a4 87a3723c 00000000 00000000 00004c28 00000000 0000103b 
  0e155cef 2f52a454 00000000 b6e7e516 b6d14852 0004cbe3 00000000 
df1ed7d7 40efef15
0001ea38  00000000 00000000 00000000 00000000 00000000 00000000 00000000 
  011a9ce9 04a60bd1 00000000 04a60a8e 04a5e0d5 00000d35 00000000 
00000000 1d9453b8


Thank you
Eric Dumazet



