From: Steve Modica <modica@sgi.com>
Subject: Re: mod_timer improvement
Date: Thu, 02 Oct 2003 12:15:14 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7C5D22.7010103@sgi.com>
References: <3F7C5863.1080403@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <3F7C5863.1080403@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

D'OH! Sorry about the formatting.  I think this is better:


@@ -207,6 +207,14 @@
         int ret;
         unsigned long flags;

+        /*
+        * This is a common optimization triggered by the
+        * networking code - if the timer is re-modified
+        * to be the same thing then just return:
+        */
+        if (timer->expires == expires && timer_pending(timer))
+               return 1;
+
         spin_lock_irqsave(&timerlist_lock, flags);
         timer->expires = expires;
         ret = detach_timer(timer);



-- 
Steve Modica
work: 651-683-3224
mobile: 651-261-3201
MTS-Technical Lead
"Give a man a fish, and he will eat for a day, hit him with a fish and
he leaves you alone" - me
