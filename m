From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Remove usage of net_device last_rx member
Date: Wed, 18 Jan 2017 09:23:44 -0800
Message-ID: <1484760224.13165.108.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170118164501.1934-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 b.a.t.m.a.n@lists.open-mesh.org, linux-m68k@lists.linux-m68k.org,
 intel-wired-lan@lists.osuosl.org, Jay Vosburgh <j.vosburgh@gmail.com>,
 Veaceslav Falico <vfalico@gmail.com>, Andy Gospodarek <andy@greyhouse.net>,
 Mirko Lindner <mlindner@marvell.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170118164501.1934-1-tklauser@distanz.ch>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Wed, 2017-01-18 at 17:45 +0100, Tobias Klauser wrote:
> The network stack no longer uses the last_rx member of struct net_device
> since the bonding driver switched to use its own private last_rx in
> commit 9f242738376d ("bonding: use last_arp_rx in slave_last_rx()").
> 
> However, some drivers still (ab)use the field for their own purposes and
> some driver just update it without actually using it.
> 
> Previously, there was an accompanying comment for the last_rx member
> added in commit 4dc89133f49b ("net: add a comment on netdev->last_rx")
> which asked drivers not to update is, unless really needed. However,
> this commend was removed in commit f8ff080dacec ("bonding: remove
> useless updating of slave->dev->last_rx"), so some drivers added later
> on still did update last_rx.
> 
> Remove all usage of last_rx and switch three drivers (sky2, atp and
> smc91c92_cs) which actually read and write it to use their own private
> copy in netdev_priv.
> 
> Compile-tested with allyesconfig and allmodconfig on x86 and arm.

SGTM, thanks a lot for doing this Tobias.

Acked-by: Eric Dumazet <edumazet@google.com>
