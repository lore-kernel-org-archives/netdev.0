From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] catch up device stats when multicast >
	total frames
Date: Tue, 5 Aug 2008 13:15:29 +0100
Message-ID: <20080805121527.GZ10471@solarflare.com>
References: <20080805115018.GB22123@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080805115018.GB22123@hmsreliant.think-freely.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> Hey-
> 	REcently observed a problem wherein, if a BMC or other IPMI device is
> attached to a NIC, multicast frames can be consumed by the aformentioned device
> without ever being seen by the driver.  Since multicast frames are counted in
> the hardware and the total frame counter is counted in the driver napi routine,

I'd be surprised if the hardware does not also maintain a total frame
counter.  If not, you can possibly calculate the total as good + bad
packets, or unicast + multicast + broadcast + bad, or something like that.

[...]
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -3761,6 +3761,8 @@ e1000_update_stats(struct e1000_adapter *adapter)
>  	/* Fill out the OS statistics structure */
>  	adapter->net_stats.multicast = adapter->stats.mprc;
>  	adapter->net_stats.collisions = adapter->stats.colc;
> +	if (adapter->net_stats.rx_packets < adapter->net_stats.multicast)
> +		adapter->net_stats.rx_packets = adapter->net_stats.multicast;
>  
>  	/* Rx Errors */
>  
[...]

This is a botch - it means the numbers can't be so obviously wrong, but
doesn't make them correct.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
