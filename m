From: Grant Grundler <iod00d@hp.com>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 13:56:50 -0800
Message-ID: <20050120215650.GB14521@esmail.cup.hp.com>
References: <5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
	<20050119144711.3fdd3d93.davem@davemloft.net>
	<20050119151853.259de49a@dxpl.pdx.osdl.net>
	<20050119164640.6c67bdfa.davem@davemloft.net>
	<52r7kgu5n5.fsf@topspin.com>
	<20050119230526.393a5184.davem@davemloft.net>
	<1106229084.5812.40.camel@tsc-6.cph.tpack.net>
	<20050120133420.317bea31.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, eric.lemoine@gmail.com, hadi@cyberus.ca,
	ak@suse.de, openib-general@openib.org,
	Tommy Christensen <tommy.christensen@tpack.net>, kaber@trash.net,
	shemminger@osdl.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050120133420.317bea31.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 20, 2005 at 01:34:20PM -0800, David S. Miller wrote:
> Even worse is that this breaks the acenic driver too because
> it does this:
> 
> 	unsigned long maxjiff = jiffies + 3*HZ;
> 
> 	if (time_before(jiffies, maxjiff)) {
> 		barrier();
> 		cpu_relax();
> 		goto restart;
> 	}
> 
> in it's ->hard_start_xmit() routine.
> 
> I was auditing spin_lock_irq() usage in ->hard_start_xmit()
> routines when I caught this.
> 
> This one isn't impossible to fix though.  We can replace the
> jiffies games with a udelay/mdelay and a "maxloop" variable.
> Any takers?

I saw the next mail suggesting to revert the changes because of more fallout.

But if/when acenic needs changes like those proposed above, I can implement
and test proposed changes if folks have the patience to wait a week or so.
acenic is no where on my "official HP supported NICs" list but I happen
to have the HW/infrastructure to test them.

grant
