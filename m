From: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
Subject: Re:
	=?iso-8859-1?q?=5Bvirtio-net=5D=5BPATCH=5D_Don=27t_ar?=
	=?iso-8859-1?q?m_tx_hrtimer_with_a=09constant_500us_each_transmit?=
Date: Tue, 18 Dec 2007 18:24:56 +1100
Message-ID: <200712181824.57235.rusty@rustcorp.com.au>
References: <475FD9E8.1060109@qumranet.com>
	<200712181101.14916.rusty@rustcorp.com.au>
	<47675AE0.8050808@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	virtualization <virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Return-path: <kvm-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <47675AE0.8050808-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Content-Disposition: inline
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

On Tuesday 18 December 2007 16:30:08 Avi Kivity wrote:
> Rusty Russell wrote:
> >     Yes, I pondered this when I wrote the code.  On the one hand, it's a
> > low-probability pathological corner case, on the other, your patch
> > reduces the number of timer reprograms in the normal case.
>
> One thing that came up in our discussions is to let the host do the
> timer processing instead of the guest.  When tx exit mitigation is
> enabled, the guest bumps the queue pointer, but carefully refrains from
> kicking the host.  The host polls the tx pointer using a timer, kicking
> itself periodically; if polling yields no packets it disables tx exit
> mitigation.  This saves the guest the bother of programming the timer,
> which presumably requires an exit if the timer is the closest one to
> expiration.
>
> [btw, this can be implemented in virtqueue rather than virtio-net, no?]

Yes, the current patch is a hack (look at the hardcoded constant); wanted to 
see how much it helps, if any.

More sophisticated timer management would be a definite win... funny, I have a 
patch here which helps that....

Rusty.

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
