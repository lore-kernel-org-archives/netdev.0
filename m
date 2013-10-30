From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netback: allocate xenvif
 arrays using vzalloc.
Date: Wed, 30 Oct 2013 06:54:02 -0700
Message-ID: <1383141242.4857.36.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131029152628.GA3065@citrix.com>
	<1383061430.5464.41.camel@edumazet-glaptop.roam.corp.google.com>
	<20131029184647.GA3261@citrix.com>
	<1383089055.4176.1.camel@edumazet-glaptop.roam.corp.google.com>
	<1383089532.4857.1.camel@edumazet-glaptop.roam.corp.google.com>
	<20131030103958.GB3261@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, david.vrabel@citrix.com,
	malcolm.crossley@citrix.com, andrew.bennieston@citrix.com
To: Joby Poriyath <joby.poriyath@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <20131030103958.GB3261@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-30 at 10:39 +0000, Joby Poriyath wrote:

> The net_device allocation rule {linux/Documentation/networking/netdevices.txt} states
> that net_device struct must be allocated using kmalloc.
> 
> Is this safe to do?

As long as the freeing path is aware of the possibility the memory is
either allocated with vmalloc() or kmalloc(), we are safe.
