From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 1/6] mac802154: Immediately retry
 sending failed packets
Date: Tue, 02 Apr 2013 21:59:37 -0400
Message-ID: <515B8D09.9050304@signal11.us>
References: <515B4D79.40805@signal11.us> <20130402231319.GD28141@ws>
	<515B84EB.8020006@signal11.us>
	<20130402.215625.1555279506975246223.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20130402.215625.1555279506975246223.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/02/2013 09:56 PM, David Miller wrote:
> From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
> Date: Tue, 02 Apr 2013 21:24:59 -0400
>
>> I like it for a couple of reasons.
>> 1. Most supported devices have only single packet output buffer, so
>> blocking in the driver is the most straight-forward way to handle it.
>> The alternative is to make each driver have a workqueue for xmit() (to
>> lift the blocking out from atomic context). This makes each driver simpler.
>>
>> 2. All of the flow control can be handled one time in the mac802154 layer.
> We have a perfectly working flow control mechanism in the generic
> networking queuing layer.  Please use it instead of inventing things.

I'm pretty sure that's what I'm doing in [1]. When I say "flow control
can be handled," I mean managing calls to netif_stop_queue() and
netif_wake_queue(). Is there something else I should be doing instead?

> If it does not meet your needs, fix it, rather than go off and do
> your own thing.  That way everyone benfits, not just you.

Fully agreed.

Alan.

[1] http://www.spinics.net/lists/netdev/msg231483.html


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
