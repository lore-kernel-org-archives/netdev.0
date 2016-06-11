From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] bridge: Fix incorrect re-injection of
 STP packets
Date: Fri, 10 Jun 2016 22:42:12 -0700 (PDT)
Message-ID: <20160610.224212.426571796038760142.davem@davemloft.net>
References: <1465290418-8015-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, fw@strlen.de,
	jiri@mellanox.com, nogahf@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, shmulik.ladkani@gmail.com
To: idosch@mellanox.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1465290418-8015-1-git-send-email-idosch@mellanox.com>
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

From: Ido Schimmel <idosch@mellanox.com>
Date: Tue, 7 Jun 2016 12:06:58 +0300

> Commit 8626c56c8279 ("bridge: fix potential use-after-free when hook
> returns QUEUE or STOLEN verdict") fixed incorrect usage of NF_HOOK's
> return value by consuming packets in okfn via br_pass_frame_up().
> 
> However, this function re-injects packets to the Rx path with skb->dev
> set to the bridge device, which breaks kernel's STP, as all STP packets
> appear to originate from the bridge device itself.
> 
> Instead, if STP is enabled and bridge isn't a 802.1ad bridge, then learn
> packet's SMAC and inject it back to the Rx path for further processing
> by the packet handlers.
> 
> The patch also makes netfilter's behavior consistent with regards to
> packets destined to the Bridge Group Address, as no hook registered at
> LOCAL_IN will ever be called, regardless if STP is enabled or not.
> 
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Fixes: 8626c56c8279 ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>

Applied, thanks.
