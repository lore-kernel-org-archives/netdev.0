From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH v2 09/13] net: Rework pasemi_mac driver to use of_mdio
	infrastructure
Date: Sun, 22 Mar 2009 10:47:10 -0500
Message-ID: <20090322154710.GA6473@lixom.net>
References: <20090321222047.20493.87335.stgit@localhost.localdomain>
	<20090321222901.20493.67103.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, davem@davemloft.net, afleming@freescale.com,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20090321222901.20493.67103.stgit@localhost.localdomain>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 21, 2009 at 04:29:01PM -0600, Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> This patch simplifies the driver by making use of more common code.

Did you ever try building it? pasemi_defconfig gives me:

drivers/net/pasemi_mac.c: In function 'pasemi_mac_phy_init':
drivers/net/pasemi_mac.c:1102: error: implicit declaration of function 'of_phy_connect'
drivers/net/pasemi_mac.c:1103: warning: assignment makes pointer from integer without a cast
drivers/net/pasemi_mac.c:1114: warning: label 'err' defined but not used
drivers/net/pasemi_mac.c:1092: warning: unused variable 'ret'
drivers/net/pasemi_mac.c:1091: warning: unused variable 'r'
drivers/net/pasemi_mac.c:1090: warning: unused variable 'prop'
drivers/net/pasemi_mac.c:1089: warning: unused variable 'ph'
make[2]: *** [drivers/net/pasemi_mac.o] Error 1

The changes needed are trivial, include <linux/of_mdio.h> and remove the
variables, label and following code. I could send a patch but that's likely
more of a hassle than you fixing it up yourself?

Otherwise, with the above changes, seems to test out ok on my Electra.
When you checkin the changes, feel free to add:

Tested-by: Olof Johansson <olof@lixom.net>
Acked-by: Olof Johansson <olof@lixom.net>

to it.

-Olof
