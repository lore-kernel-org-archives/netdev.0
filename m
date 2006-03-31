From: "Jeffrey V. Merkey" <jmerkey@wolfmountaingroup.com>
Subject: Re: [PATCH]: e1000: prevent statistics from getting garbled during
 reset.
Date: Thu, 30 Mar 2006 21:14:56 -0700
Message-ID: <442CACC0.1060308@wolfmountaingroup.com>
References: <20060330213928.GQ2172@austin.ibm.com> <20060331000208.GS2172@austin.ibm.com> <442C8069.507@wolfmountaingroup.com> <20060331003506.GU2172@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linuxppc-dev@ozlabs.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751239AbWCaEMO@vger.kernel.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060331003506.GU2172@austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:

>On Thu, Mar 30, 2006 at 06:05:45PM -0700, Jeff V. Merkey wrote:
>  
>
>>Linas Vepstas wrote:
>>    
>>
>
>Well, these comments have nothing to do with my patch, but ... 
>anyway ... 
>
>  
>
>>The driver also needs to be fixed to allow clearing of the stats (like 
>>all the other adapter drivers). At present, when I run performance
>>and packet drop counts on the cards, I cannot reset the stats with this 
>>code because the driver stores them in the e100_adapter
>>structure. This is busted.
>>
>>This function:
>>
>>int clear_network_device_stats(BYTE *name)
>>    
>>
>
>I couldn't find such a function in the kernel.
> 
>  
>
>>does not work on e1000 due to this section of code:
>>
>>void
>>e1000_update_stats(struct e1000_adapter *adapter)
>>{
>>
>>adapter->stats.xofftxc += E1000_READ_REG(hw, XOFFTXC);
>>adapter->stats.fcruc += E1000_READ_REG(hw, FCRUC);
>>    
>>
>
>These are hardware stats ... presumably useless without
>a detailed understanding of the guts of the e1000.
>
>  
>
>>//NOTE These stats need to be stored in the stats structure so they can 
>>be cleared by
>>statistics monitoring programs.
>>    
>>
>
>I can't imagine what generic interface would allow these 
>to be viewed.
>
>  
>
>>/* Fill out the OS statistics structure */
>>
>>adapter->net_stats.rx_packets = adapter->stats.gprc;
>>adapter->net_stats.tx_packets = adapter->stats.gptc;
>>adapter->net_stats.rx_bytes = adapter->stats.gorcl;
>>adapter->net_stats.tx_bytes = adapter->stats.gotcl;
>>    
>>
>
>Now *these* are generic ... and fixing this so that the 
>stats increment instead of over-riding would take 
>maybe half-an-hour or so; this is not hard to do ... !? 
>
>Do you want me to write a patch to do this?
>
>--lina
>  
>
Yes, we need one. The adapter needs to maintain these stats from the
registers in the kernel structure and not
its own local variables. That way, when someone calls to clear the stats
for testing and analysis purposes,
they zero out and are reset.

The code fragment above is in our analysis code not the kernel, but we
use it to test performance of various
vendor cards. It's provided as an example of this capability.

Jeff

>-
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/
>
>  
>
