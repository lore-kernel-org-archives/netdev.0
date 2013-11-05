From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH] net: mv643xx_eth: Add missing phy_addr_set in DT mode
Date: Tue, 05 Nov 2013 23:12:00 +0100
Message-ID: <87sivacxcf.fsf@natisbad.org>
References: <1383611239-14556-1-git-send-email-jgunthorpe@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Lennert Buytenhek <buytenh@wantstofly.org>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1383611239-14556-1-git-send-email-jgunthorpe@obsidianresearch.com>
 (Jason Gunthorpe's message of "Mon, 4 Nov 2013 17:27:19 -0700")
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

Hi Jason,

Jason Gunthorpe <jgunthorpe@obsidianresearch.com> writes:

> Commit cc9d4598 'net: mv643xx_eth: use of_phy_connect if phy_node
> present' made the call to phy_scan optional, if the DT has a link to
> the phy node.
>
> However phy_scan has the side effect of calling phy_addr_set, which
> writes the phy MDIO address to the ethernet controller. If phy_addr_set
> is not called, and the bootloader has not set the correct address then
> the driver will fail to function.

Thanks *a lot* for fixing this one! I had the issue on my ReadyNAS 102
(Armada 370 based) which I had put on a todo list and temporarily
workarounded by including a 'ping whatever' call in my u-boot env in
order to force it to do the init. Without it, I was unable to properly
use the interface. With your fix, after multiple reboots to test it,
everything works as expected. So, FWIW: 

Tested-by: Arnaud Ebalard <arno@natisbad.org>

Cheers,

a+
