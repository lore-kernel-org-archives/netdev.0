From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Don't include NDA_VLAN for FDB
 entries with vid 0
Date: Thu, 31 Jul 2014 12:19:23 -0700 (PDT)
Message-ID: <20140731.121923.1328533021640488126.davem@davemloft.net>
References: <1406694711-8521-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1406694711-8521-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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
Date: Wed, 30 Jul 2014 13:31:51 +0900

> An FDB entry with vlan_id 0 doesn't mean it is used in vlan 0, but used when
> vlan_filtering is disabled.
> 
> There is inconsistency around NDA_VLAN whose payload is 0 - even if we add
> an entry by RTM_NEWNEIGH without any NDA_VLAN, and even though adding an
> entry with NDA_VLAN 0 is prohibited, we get an entry with NDA_VLAN 0 by
> RTM_GETNEIGH.
> 
> Dumping an FDB entry with vlan_id 0 shouldn't include NDA_VLAN.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

This is clearly the right thing to do, since upon FDB addition we reject
NDA_VLAN attributes with value zero.

Applied, thanks.
