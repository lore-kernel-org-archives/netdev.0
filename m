From: Ian Campbell <ijc@hellion.org.uk>
Subject: Bug#764162: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Wed, 05 Nov 2014 08:39:26 +0000
Message-ID: <1415176766.31613.7.camel@hellion.org.uk>
References: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
	 <20141104142020.GA6728@magnum.frso.rivierawaves.com>
Reply-To: Ian Campbell <ijc@hellion.org.uk>, 764162@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 netdev@vger.kernel.org, David Miller <davem@davemloft.net>, Thomas
 Petazzoni <thomas.petazzoni@free-electrons.com>, Gregory Clement
 <gregory.clement@free-electrons.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Lior Amsalem <alior@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 764162@bugs.debian.org
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <bounce-debian-bugs-rc=glddbr-debian-bugs-rc=gmane.org@lists.debian.org>
Resent-Message-ID: <handler.764162.B764162.141517677525902@bugs.debian.org>
In-Reply-To: <20141104142020.GA6728@magnum.frso.rivierawaves.com>
List-URL: <http://lists.debian.org/debian-bugs-rc/>
List-Post: <mailto:debian-bugs-rc@lists.debian.org>
List-Help: <mailto:debian-bugs-rc-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-rc-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-rc-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, 2014-11-04 at 15:20 +0100, Karl Beldan wrote:
> On Sat, Nov 01, 2014 at 12:30:19PM -0300, Ezequiel Garcia wrote:
> > Several users ([1], [2]) have been reporting data corruption with TSO on
> > Kirkwood platforms (i.e. using the mv643xx_eth driver).
> > 
> > Until we manage to find what's causing this, this simple patch will make
> > the TSO path disabled by default. This patch should be queued for stable,
> > fixing the TSO feature introduced in v3.16.
> > 
> > The corruption itself is very easy to reproduce: checking md5sum on a mounted
> > NFS directory gives a different result each time. Same tests using the mvneta
> > driver (Armada 370/38x/XP SoC) pass with no issues.
> > 
> > Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
> > are well received.
> > 
> 
> Hi,
> 
> Can you try this :

It fixes things for me, thanks!

Tested-by: Ian Campbell <ijc@hellion.org.uk>

> @@ -1067,7 +1082,8 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
>  		txq->tx_desc_count--;
>  
>  		skb = NULL;
> -		if (cmd_sts & TX_LAST_DESC)
> +		if ((cmd_sts & (TX_LAST_DESC | TX_ENABLE_INTERRUPT)) ==
> +			       (TX_LAST_DESC | TX_ENABLE_INTERRUPT))
>  			skb = __skb_dequeue(&txq->tx_skb);
>  
>  		if (cmd_sts & ERROR_SUMMARY) {
> 
