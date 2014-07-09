From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: Re: [RFC 7/7] net: don't check for active hrtimer after adding it
Date: Wed, 9 Jul 2014 20:53:51 +0530
Message-ID: <CAKohponPJO+RGaCG8HC9d3iNKhV35Ss33XAdcQ6qus5ybeDuTQ@mail.gmail.com>
References: <cover.1404888801.git.viresh.kumar@linaro.org>
	<a8994b5dda7599c0d8ce9f66aef40b8587acf691.1404888801.git.viresh.kumar@linaro.org>
	<53BD1A56.7000902@arm.com>
	<CAKohpomdxB7ui4WQTWfJva9YYYqcfs6cabsC+SyYijdRUViT_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "tglx@linutronix.de" <tglx@linutronix.de>,
	"linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>,
	"fweisbec@gmail.com" <fweisbec@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"preeti@linux.vnet.ibm.com" <preeti@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arvind Chauhan <Arvind.Chauhan@arm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Chris Redpath <Chris.Redpath@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKohpomdxB7ui4WQTWfJva9YYYqcfs6cabsC+SyYijdRUViT_g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9 July 2014 16:14, Viresh Kumar <viresh.kumar@linaro.org> wrote:
> Yeah, it looks like we can get rid of this. Also,
>
>         } while (t.task && pkt_dev->running && !signal_pending(current));
>
> is present in the closing "}" of do-while loop and probably we
> don't need to check t.task here as well.

Actually No. t.task is modified from hrtimer handler and so this check
would stay:

Diff I have added to this patch:

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f911acd..cc2694e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2187,8 +2187,7 @@ static void spin(struct pktgen_dev *pkt_dev,
ktime_t spin_until)
                        set_current_state(TASK_INTERRUPTIBLE);
                        hrtimer_start_expires(&t.timer, HRTIMER_MODE_ABS);

-                       if (likely(t.task))
-                               schedule();
+                       schedule();

                        hrtimer_cancel(&t.timer);
                } while (t.task && pkt_dev->running &&
!signal_pending(current));
