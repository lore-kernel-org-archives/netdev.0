From: Dor Laor <dor.laor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [virtio-net][PATCH] Don't arm tx hrtimer with a
 constant 500us each transmit
Date: Tue, 18 Dec 2007 14:55:27 +0200
Message-ID: <4767C33F.1050308@qumranet.com>
References: <475FD9E8.1060109@qumranet.com>
	<200712181101.14916.rusty@rustcorp.com.au>
Reply-To: dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0762625934=="
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization <virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <200712181101.14916.rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============0762625934==
Content-Type: multipart/alternative;
	boundary="------------070200070802000402000908"

This is a multi-part message in MIME format.
--------------070200070802000402000908
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Rusty Russell wrote:
> On Wednesday 12 December 2007 23:54:00 Dor Laor wrote:
>   
>> commit 763769621d271d92204ed27552d75448587c1ac0
>> Author: Dor Laor <dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
>> Date:   Wed Dec 12 14:52:00 2007 +0200
>>
>>     [virtio-net][PATCH] Don't arm tx hrtimer with a constant 50us each
>> transmit
>>
>>     The current start_xmit sets 500us hrtimer to kick the host.
>>     The problem is that if another xmit happens before the timer was
>> fired then
>>     the first xmit will have to wait additional 500us.
>>     This patch does not re-arm the timer if there is existing one.
>>     This will shorten the latency for tx.
>>     
>
> Hi Dor!
>
>     Yes, I pondered this when I wrote the code.  On the one hand, it's a 
> low-probability pathological corner case, on the other, your patch reduces 
> the number of timer reprograms in the normal case.
>
> So I've applied it, thanks!
> Rusty.
>
>
>   
Thanks, it actually improved my tx performance in 20%!
Expecting the host side timer with your new patch.
Cheers,
Dor.
>
>
>   
>>     Signed-off-by: Dor Laor <dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 7b051d5..8bb17d1
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -406,10 +405,10 @@ again:
>>          virtio_debug(vdebug, "%s: before calling kick %d\n",
>> __FUNCTION__, __LINE__);
>>          vi->svq->vq_ops->kick(vi->svq);
>>          vi->out_num = 0;
>> -    } else {
>> -        vi->stats.hrtimer_starts++;
>> -        hrtimer_start(&vi->tx_timer, ktime_set(0,500000),
>> -                  HRTIMER_MODE_REL);
>> +    } else if (!hrtimer_is_queued(&vi->tx_timer)) {
>> +            vi->stats.hrtimer_starts++;
>> +            hrtimer_start(&vi->tx_timer, ktime_set(0,500000),
>> +                      HRTIMER_MODE_REL);
>>      }
>>      return 0;
>>  }
>>     
>
>
>
>   


--------------070200070802000402000908
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
Rusty Russell wrote:
<blockquote cite="mid:200712181101.14916.rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org"
 type="cite">
  <pre wrap="">On Wednesday 12 December 2007 23:54:00 Dor Laor wrote:
  </pre>
  <blockquote type="cite">
    <pre wrap="">commit 763769621d271d92204ed27552d75448587c1ac0
Author: Dor Laor <a class="moz-txt-link-rfc2396E" href="mailto:dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org">&lt;dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org&gt;</a>
Date:   Wed Dec 12 14:52:00 2007 +0200

    [virtio-net][PATCH] Don't arm tx hrtimer with a constant 50us each
transmit

    The current start_xmit sets 500us hrtimer to kick the host.
    The problem is that if another xmit happens before the timer was
fired then
    the first xmit will have to wait additional 500us.
    This patch does not re-arm the timer if there is existing one.
    This will shorten the latency for tx.
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Hi Dor!

    Yes, I pondered this when I wrote the code.  On the one hand, it's a 
low-probability pathological corner case, on the other, your patch reduces 
the number of timer reprograms in the normal case.

So I've applied it, thanks!
Rusty.


  </pre>
</blockquote>
Thanks, it actually improved my tx performance in 20%!<br>
Expecting the host side timer with your new patch.<br>
Cheers,<br>
Dor.<br>
<blockquote cite="mid:200712181101.14916.rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org"
 type="cite">
  <pre wrap="">


  </pre>
  <blockquote type="cite">
    <pre wrap="">    Signed-off-by: Dor Laor <a class="moz-txt-link-rfc2396E" href="mailto:dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org">&lt;dor.laor-atKUWr5tajBWk0Htik3J/w@public.gmane.org&gt;</a>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7b051d5..8bb17d1
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -406,10 +405,10 @@ again:
         virtio_debug(vdebug, "%s: before calling kick %d\n",
__FUNCTION__, __LINE__);
         vi-&gt;svq-&gt;vq_ops-&gt;kick(vi-&gt;svq);
         vi-&gt;out_num = 0;
-    } else {
-        vi-&gt;stats.hrtimer_starts++;
-        hrtimer_start(&amp;vi-&gt;tx_timer, ktime_set(0,500000),
-                  HRTIMER_MODE_REL);
+    } else if (!hrtimer_is_queued(&amp;vi-&gt;tx_timer)) {
+            vi-&gt;stats.hrtimer_starts++;
+            hrtimer_start(&amp;vi-&gt;tx_timer, ktime_set(0,500000),
+                      HRTIMER_MODE_REL);
     }
     return 0;
 }
    </pre>
  </blockquote>
  <pre wrap=""><!---->


  </pre>
</blockquote>
<br>
</body>
</html>

--------------070200070802000402000908--


--===============0762625934==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
--===============0762625934==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
kvm-devel mailing list
kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/kvm-devel

--===============0762625934==--
