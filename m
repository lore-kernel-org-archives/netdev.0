From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: kernel BUG at /usr/src/linux-2.6.25/kernel/workqueue.c:224!
	(r8169?)
Date: Mon, 21 Apr 2008 22:34:58 +0200
Message-ID: <20080421203458.GA2931@electric-eye.fr.zoreil.com>
References: <76366b180804201548g309ae6cci286ed6552f3cb71e@mail.gmail.com> <76366b180804202016l19ac362cyb814781449f81e9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Andrew Paprocki <andrew@ishiboo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755451AbYDUUxW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <76366b180804202016l19ac362cyb814781449f81e9a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Paprocki <andrew@ishiboo.com> :
> I just received a similar bug on workqueue.c:223 while I was not doing
> anything with the card. These bugs seem to have increased with
> frequency when running under 2.6.25. It used to take me some time to
> cause a problem to appear under 2.6.24, but under 2.6.25 they appear
> very readily. I was actually not touching the machine at all when this
> appeared on the console:

Does the patch below decrease the frequency of the bug ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3acfeea..6ee9db1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2398,8 +2398,6 @@ static void rtl8169_wait_for_quiescence(struct net_device *dev)
 	rtl8169_irq_mask_and_ack(ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
-	tp->intr_mask = 0xffff;
-	RTL_W16(IntrMask, tp->intr_event);
 	napi_enable(&tp->napi);
 #endif
 }

-- 
Ueimor
