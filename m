From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] netlink: Re-add locking to netlink_lookup() and seq
 walker
Date: Tue, 21 Oct 2014 09:04:24 +0200
Message-ID: <20141021070424.GA4161@osiris>
References: <20141011083627.GB5074@osiris>
 <1413055964.9362.50.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141011222514.GA14186@casper.infradead.org>
 <20141020082107.GB4268@osiris>
 <20141020195355.GA2299@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	paulmck@linux.vnet.ibm.com,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ursula Braun <braunu@de.ibm.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141020195355.GA2299@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 20, 2014 at 08:53:55PM +0100, Thomas Graf wrote:
> Heiko,
> 
> Can you test the following patch:
> 
> The synchronize_rcu() in netlink_release() introduces unacceptable
> latency. Reintroduce minimal lookup so we can drop the
> synchronize_rcu() until socket destruction has been RCUfied.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
>  net/netlink/af_netlink.c | 37 +++++++++++++++++++++++++------------
>  1 file changed, 25 insertions(+), 12 deletions(-)

Thanks a lot! Your patch fixes the issue for me.

Reported-and-tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>
