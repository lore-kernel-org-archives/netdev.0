From: Jesper Dangaard Brouer via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH RFC 08/11] net/mlx5e: XDP fast RX drop bpf
 programs support
Date: Thu, 8 Sep 2016 09:19:27 +0200
Message-ID: <20160908091927.021dea5a@redhat.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
	<1473252152-11379-9-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMhh=fu+mrCGAjv1PDdGn9GPLJv9MssMzwzvppoqZUY01A@mail.gmail.com>
	<CALzJLG8_F28kQOPqTTLJRMsf9BOQvm3K2hAraCzabnXV4yKUgg@mail.gmail.com>
	<CALx6S35b_MZXiGR-b1SB+VNifPHDfQNDZdz-6vk0t3bKNwen+w@mail.gmail.com>
	<CALzJLG9bu3-=Ybq+Lk1fvAe5AohVHAaPpa9RQqd1QVe-7XPyhw@mail.gmail.com>
Reply-To: Jesper Dangaard Brouer <brouer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rana Shahout <ranas-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <CALzJLG9bu3-=Ybq+Lk1fvAe5AohVHAaPpa9RQqd1QVe-7XPyhw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Sep 2016 20:07:01 +0300
Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:

> On Wed, Sep 7, 2016 at 7:54 PM, Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org> wrote:
> > On Wed, Sep 7, 2016 at 7:48 AM, Saeed Mahameed
> > <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org> wrote:  
> >> On Wed, Sep 7, 2016 at 4:32 PM, Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:  
> >>> On Wed, Sep 7, 2016 at 3:42 PM, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> >>>  
> >>>> Packet rate performance testing was done with pktgen 64B packets and on
> >>>> TX side and, TC drop action on RX side compared to XDP fast drop.
> >>>>
> >>>> CPU: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
> >>>>
> >>>> Comparison is done between:
> >>>>         1. Baseline, Before this patch with TC drop action
> >>>>         2. This patch with TC drop action
> >>>>         3. This patch with XDP RX fast drop
> >>>>
> >>>> Streams    Baseline(TC drop)    TC drop    XDP fast Drop
> >>>> --------------------------------------------------------------
> >>>> 1           5.51Mpps            5.14Mpps     13.5Mpps
> >>>> 2           11.5Mpps            10.0Mpps     25.1Mpps
> >>>> 4           16.3Mpps            17.2Mpps     35.4Mpps
> >>>> 8           29.6Mpps            28.2Mpps     45.8Mpps*
> >>>> 16          34.0Mpps            30.1Mpps     45.8Mpps*  
> >>>
> >>> Rana, Guys, congrat!!
> >>>
> >>> When you say X streams, does each stream mapped by RSS to different RX ring?
> >>> or we're on the same RX ring for all rows of the above table?  
> >>
> >> Yes, I will make this more clear in the actual submission,
> >> Here we are talking about different RSS core rings.
> >>  
> >>>
> >>> In the CX3 work, we had X sender "streams" that all mapped to the same RX ring,
> >>> I don't think we went beyond one RX ring.  
> >>
> >> Here we did, the first row is what you are describing the other rows
> >> are the same test
> >> with increasing the number of the RSS receiving cores, The xmit side is sending
> >> as many streams as possible to be as much uniformly spread as possible
> >> across the
> >> different RSS cores on the receiver.
> >>  
> > Hi Saeed,
> >
> > Please report CPU utilization also. The expectation is that
> > performance should scale linearly with increasing number of CPUs (i.e.
> > pps/CPU_utilization should be constant).
> >  
> 
> That was my expectation too.

Be careful with such expectations at these extreme speeds, because we
are starting to hit PCI-express limitations and CPU cache-coherency
limitations (if any atomic/RMW operations still exists per packet).

Consider that in the small packet size 64 bytes case, the drivers PCI bandwidth
need/overhead is actually quite large, as every descriptor also 64
bytes transferred.

 
> Anyway we will share more accurate results when we have them, with CPU
> utilization statistics as well.

It is interesting to monitor the CPU utilization, because (if C-states
are enabled) you will likely see the CPU freq be reduced or even enter
CPU idle states, in-case your software (XDP) gets faster than the HW
(PCI or NIC).  I've seen that happen with mlx4/CX3-pro.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
