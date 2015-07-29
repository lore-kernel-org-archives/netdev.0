From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Fix network header pointer for
 vlan tagged packets
Date: Wed, 29 Jul 2015 12:21:23 -0700 (PDT)
Message-ID: <20150729.122123.754536415828052026.davem@davemloft.net>
References: <1438077937-16134-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	ivecera@redhat.com
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1438077937-16134-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Tue, 28 Jul 2015 19:05:37 +0900

> There are several devices that can receive vlan tagged packets with
> CHECKSUM_PARTIAL like tap, possibly veth and xennet.
> When (multiple) vlan tagged packets with CHECKSUM_PARTIAL are forwarded
> by bridge to a device with the IP_CSUM feature, they end up with checksum
> error because before entering bridge, the network header is set to
> ETH_HLEN (not including vlan header length) in __netif_receive_skb_core(),
> get_rps_cpu(), or drivers' rx functions, and nobody fixes the pointer later.
> 
> Since the network header is exepected to be ETH_HLEN in flow-dissection
> and hash-calculation in RPS in rx path, and since the header pointer fix
> is needed only in tx path, set the appropriate network header on forwarding
> packets.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Applied, thank you.
