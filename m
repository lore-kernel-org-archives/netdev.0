From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: mdb: avoid uninitialized variable
	warning
Date: Tue, 16 Feb 2016 15:37:58 -0500 (EST)
Message-ID: <20160216.153758.1508523820142527071.davem@davemloft.net>
References: <1455116946-2948649-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, jiri@mellanox.com,
	eladr@mellanox.com, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1455116946-2948649-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 10 Feb 2016 16:09:02 +0100

> A recent change to the mdb code confused the compiler to the point
> where it did not realize that the port-group returned from
> br_mdb_add_group() is always valid when the function returns a nonzero
> return value, so we get a spurious warning:
> 
> net/bridge/br_mdb.c: In function 'br_mdb_add':
> net/bridge/br_mdb.c:542:4: error: 'pg' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>     __br_mdb_notify(dev, entry, RTM_NEWMDB, pg);
> 
> Slightly rearranging the code in br_mdb_add_group() makes the problem
> go away, as gcc is clever enough to see that both functions check
> for 'ret != 0'.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 9e8430f8d60d ("bridge: mdb: Passing the port-group pointer to br_mdb module")

Applied, thanks Arnd.
