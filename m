From: Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org>
Subject: Re: [virtio-net][PATCH] Don't arm tx hrtimer with
 a	constant 500us each transmit
Date: Tue, 18 Dec 2007 07:30:08 +0200
Message-ID: <47675AE0.8050808@qumranet.com>
References: <475FD9E8.1060109@qumranet.com>
	<200712181101.14916.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
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

One thing that came up in our discussions is to let the host do the 
timer processing instead of the guest.  When tx exit mitigation is 
enabled, the guest bumps the queue pointer, but carefully refrains from 
kicking the host.  The host polls the tx pointer using a timer, kicking 
itself periodically; if polling yields no packets it disables tx exit 
mitigation.  This saves the guest the bother of programming the timer, 
which presumably requires an exit if the timer is the closest one to 
expiration.

[btw, this can be implemented in virtqueue rather than virtio-net, no?]

-- 
Any sufficiently difficult bug is indistinguishable from a feature.


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
