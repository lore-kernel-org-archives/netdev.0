From: Steve Modica <modica@sgi.com>
Subject: mod_timer improvement
Date: Thu, 02 Oct 2003 13:20:23 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7C6C67.4010300@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry about the screwed up formatting!  I'm kinda new at this :)



*** linux/linux/kernel/timer.c       2003/08/11 20:16:19     1.23
--- linux/linux/kernel/timer.c       2003/10/01 21:09:20     1.24
*************** int mod_timer(struct timer_list *timer,
*** 207,212 ****
--- 207,220 ----
         int ret;
         unsigned long flags;

+         /*
+        * This is a common optimization triggered by the
+        * networking code - if the timer is re-modified
+        * to be the same thing then just return:
+        */
+         if (timer->expires == expires && timer_pending(timer))
+                return 1;
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
