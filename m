From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: ixgbe, don't assume mapping of numa node cpus
Date: Tue, 25 Feb 2014 12:43:05 -0500
Message-ID: <530CD629.2030607@redhat.com>
References: <1393267913-28212-1-git-send-email-prarit@redhat.com>
	<1393267913-28212-3-git-send-email-prarit@redhat.com>
	<20140225172726.GA31074@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, idos@mellanox.com,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	agospoda@redhat.com, John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>, Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20140225172726.GA31074@mtl-eit-vdi-22.mtl.labs.mlnx>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On 02/25/2014 12:27 PM, Amir Vadai wrote:
> On 24/02/14 13:51 -0500, Prarit Bhargava wrote:
>> The ixgbe driver assumes that the cpus on a node are mapped 1:1 with the
>> indexes into arrays.  This is not the case as nodes can contain, for
>> example, cpus 0-7, 33-40.
>>
>> This patch fixes this problem.
>>
>> Signed-off-by: Prarit Bhargava <prarit@redhat.com>
>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Cc: Bruce Allan <bruce.w.allan@intel.com>
>> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> Cc: Don Skidmore <donald.c.skidmore@intel.com>
>> Cc: Greg Rose <gregory.v.rose@intel.com>
>> Cc: Alex Duyck <alexander.h.duyck@intel.com>
>> Cc: John Ronciak <john.ronciak@intel.com>
>> Cc: Mitch Williams <mitch.a.williams@intel.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: nhorman@redhat.com
>> Cc: agospoda@redhat.com
>> Cc: e1000-devel@lists.sourceforge.net
>> ---
> 
> Hi,
> 
> I'm just about to send tomorrow a patch to add an helper function to
> get affinity_hint suggestion by numa_node and ring index.
> If you'd like you will be able to use it too here.
> 
> We're still doing internal review on it before sending to the mailing
> list, but this will be the declaration of the function:
> /*
>  * netif_set_rx_queue_affinity_hint - set affinity hint of rx queue
>  * @rxq: index of rx queue
>  * @numa_node: prefered numa_node
>  * @affinity_mask: the relevant cpu bit is set according to the policy
>  *
>  * This function sets the affinity_mask according to a numa aware policy.
>  * affinity_mask coulbe used as an affinity hint for the IRQ related of this
>  * rx queue.
>  * The policy is to spread rx queues across cores - local cores first.
>  *
>  * Returns 0 on success, or a negative error code.
>  */
> int netif_set_rx_queue_affinity_hint(int rxq, int numa_node,
>                                      cpumask_var_t affinity_mask);

I'm going to wait for this patch then.  Amir, please cc me.

Thanks for the info,

P.

> 
> 
> 
> Amir

------------------------------------------------------------------------------
Flow-based real-time traffic analytics software. Cisco certified tool.
Monitor traffic, SLAs, QoS, Medianet, WAAS etc. with NetFlow Analyzer
Customize your own dashboards, set traffic alerts and generate reports.
Network behavioral analysis & security monitoring. All-in-one tool.
http://pubads.g.doubleclick.net/gampad/clk?id=126839071&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
