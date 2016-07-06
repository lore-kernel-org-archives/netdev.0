From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH net] net: mvneta: set real interrupt per packet for tx_done
Date: Wed, 6 Jul 2016 07:04:31 +0200
Message-ID: <20160706050431.GA26348@1wt.eu>
References: <1467771538-31811-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, andrew@lunn.ch, linux@arm.linux.org.uk,
 jason@lakedaemon.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, Dmitri Epshtein <dima@marvell.com>, nadavh@marvell.com,
 alior@marvell.com, jaz@semihalf.com, gregory.clement@free-electrons.com,
 nitroshift@yahoo.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, sebastian.hesselbarth@gmail.com
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1467771538-31811-1-git-send-email-mw@semihalf.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jul 06, 2016 at 04:18:58AM +0200, Marcin Wojtas wrote:
> From: Dmitri Epshtein <dima@marvell.com>
> 
> Commit aebea2ba0f74 ("net: mvneta: fix Tx interrupt delay") intended to
> set coalescing threshold to a value guaranteeing interrupt generation
> per each sent packet, so that buffers can be released with no delay.
> 
> In fact setting threshold to '1' was wrong, because it causes interrupt
> every two packets. According to the documentation a reason behind it is
> following - interrupt occurs once sent buffers counter reaches a value,
> which is higher than one specified in MVNETA_TXQ_SIZE_REG(q). This
> behavior was confirmed during tests. Also when testing the SoC working
> as a NAS device, better performance was observed with int-per-packet,
> as it strongly depends on the fact that all transmitted packets are
> released immediately.
> 
> This commit enables NETA controller work in interrupt per sent packet mode
> by setting coalescing threshold to 0.

We had a discussion about this in January 2015 and I thought I sent a patch
to change it but I can't find it, so I think it was only proposed to some
users for testing. I also remember that on more recent kernels by then
(>=3.13) we observed a slightly better performance with this value set to
zero.

Acked-by: Willy Tarreau <w@1wt.eu>

Willy
