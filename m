From: Simon Kirby <sim@netnation.com>
Subject: Re: Route cache performance
Date: Tue, 23 Aug 2005 17:01:58 -0700
Message-ID: <20050824000158.GA8137@netnation.com>
References: <20050815213855.GA17832@netnation.com> <43014E27.1070104@cosmosbay.com> <20050823190852.GA20794@netnation.com> <17163.32645.202453.145416@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <17163.32645.202453.145416@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 23, 2005 at 09:56:53PM +0200, Robert Olsson wrote:

>  Yes your GC does not work at all in your 2.6 setups...Why?

Good question. :)

>  echo 50 >  /proc/sys/net/ipv4/route/gc_min_interval_ms

The output looks exactly the same with gc_min_interval_ms set to 50.

If I set it to 0, it does change a little but _still_ overflows:

rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|rt_cache|
 entries|  in_hit|in_slow_|gc_total|gc_ignor|gc_goal_|gc_dst_o|in_hlist|
        |        |     tot|        |      ed|    miss| verflow| _search|
       3|       3|       1|       1|       1|       0|       0|       0|
       4|      11|       5|       0|       0|       0|       0|       0|
       5|       5|       2|       0|       0|       0|       0|       0|
   23615|       1|   24002|   15812|       0|       0|       0|   11470|
   68692|       0|   46780|   46777|       0|    4687|       0|    4492|
   86046|       0|   18763|   18754|       0|   18754|       0|     119|
   94884|       0|    9540|    9538|       0|    9538|       0|      47|
  104901|       0|   10819|   10817|       0|   10817|       0|      61|
  114919|       0|   10817|   10818|       0|   10818|       0|      68|
  127424|       0|   13512|   13505|       0|   13505|       0|      74|
  131062|       0|   15113|   15106|       0|   15106|   10368|      28|
  131062|       0|   12503|   12482|       0|   12482|   11582|       9|
  131062|       0|    8146|    8130|       0|    8130|    7530|       5|
  131062|       0|    8204|    8194|       0|    8194|    7594|       2|
  131062|       0|    8132|    8131|       0|    8131|    7531|       5|
  131062|       0|    8196|    8195|       0|    8195|    7595|       4|
  131062|       0|    8130|    8129|       0|    8129|    7529|       8|

Something is definitely broken here.  Are the interrupts (or in this
case, NAPI) able to starve the gc somehow?

Simon-
