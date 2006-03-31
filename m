From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH]: e1000: prevent statistics from getting garbled during
	reset.
Date: Thu, 30 Mar 2006 18:35:06 -0600
Message-ID: <20060331003506.GU2172@austin.ibm.com>
References: <20060330213928.GQ2172@austin.ibm.com>
	<20060331000208.GS2172@austin.ibm.com>
	<442C8069.507@wolfmountaingroup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, linuxppc-dev@ozlabs.org,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	linux-pci@atrey.karlin.mff.cuni.cz, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: "Jeff V. Merkey" <jmerkey@wolfmountaingroup.com>
Content-Disposition: inline
In-Reply-To: <442C8069.507@wolfmountaingroup.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2006 at 06:05:45PM -0700, Jeff V. Merkey wrote:
> 
> Linas Vepstas wrote:

Well, these comments have nothing to do with my patch, but ... 
anyway ... 

> The driver also needs to be fixed to allow clearing of the stats (like 
> all the other adapter drivers). At present, when I run performance
> and packet drop counts on the cards, I cannot reset the stats with this 
> code because the driver stores them in the e100_adapter
> structure. This is busted.
> 
> This function:
> 
> int clear_network_device_stats(BYTE *name)

I couldn't find such a function in the kernel.
 
> does not work on e1000 due to this section of code:
> 
> void
> e1000_update_stats(struct e1000_adapter *adapter)
> {
> 
> adapter->stats.xofftxc += E1000_READ_REG(hw, XOFFTXC);
> adapter->stats.fcruc += E1000_READ_REG(hw, FCRUC);

These are hardware stats ... presumably useless without
a detailed understanding of the guts of the e1000.

> //NOTE These stats need to be stored in the stats structure so they can 
> be cleared by
> statistics monitoring programs.

I can't imagine what generic interface would allow these 
to be viewed.

> /* Fill out the OS statistics structure */
> 
> adapter->net_stats.rx_packets = adapter->stats.gprc;
> adapter->net_stats.tx_packets = adapter->stats.gptc;
> adapter->net_stats.rx_bytes = adapter->stats.gorcl;
> adapter->net_stats.tx_bytes = adapter->stats.gotcl;

Now *these* are generic ... and fixing this so that the 
stats increment instead of over-riding would take 
maybe half-an-hour or so; this is not hard to do ... !? 

Do you want me to write a patch to do this?

--linas
