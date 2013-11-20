From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: flush br's address entry in fdb
 when remove the bridge dev
Date: Wed, 20 Nov 2013 15:32:04 -0500 (EST)
Message-ID: <20131120.153204.1811191418900565753.davem@davemloft.net>
References: <528C172A.3090004@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	toshiaki.makita1@gmail.com, bridge@lists.linux-foundation.org,
	vyasevich@gmail.com
To: dingtianhong@huawei.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <528C172A.3090004@huawei.com>
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

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 20 Nov 2013 09:58:02 +0800

> From 241ddeaad73c7ed9e376a4b0926e79bdc3df9f58 Mon Sep 17 00:00:00 2001
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Sat, 7 Dec 2013 22:12:05 +0800
> Subject: [PATCH] bridge: flush br's address entry in fdb when remove the
>  bridge dev
> 
> When the following commands are executed:
> 
> brctl addbr br0
> ifconfig br0 hw ether <addr>
> rmmod bridge
> 
> The calltrace will occur:
 ...
> The reason is that when the bridge dev's address is changed, the
> br_fdb_change_mac_address() will add new address in fdb, but when
> the bridge was removed, the address entry in the fdb did not free,
> the bridge_fdb_cache still has objects when destroy the cache, Fix
> this by flushing the bridge address entry when removing the bridge.
> 
> v2: according to the Toshiaki Makita and Vlad's suggestion, I only
>     delete the vlan0 entry, it still have a leak here if the vlan id
>     is other number, so I need to call fdb_delete_by_port(br, NULL, 1)
>     to flush all entries whose dst is NULL for the bridge.
> 
> Suggested-by: Toshiaki Makita <toshiaki.makita1@gmail.com>
> Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied and queued up for -stable, thanks.
