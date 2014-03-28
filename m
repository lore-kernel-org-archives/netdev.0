From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bridge: Fix crash with vlan filtering and
	tcpdump
Date: Fri, 28 Mar 2014 17:14:17 -0400 (EDT)
Message-ID: <20140328.171417.1243496360817986608.davem@davemloft.net>
References: <1395971478-10689-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: vyasevic@redhat.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1395971478-10689-1-git-send-email-vyasevic@redhat.com>
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

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 27 Mar 2014 21:51:18 -0400

> When the vlan filtering is enabled on the bridge, but
> the filter is not configured on the bridge device itself,
> running tcpdump on the bridge device will result in a
> an Oops with NULL pointer dereference.  The reason
> is that br_pass_frame_up() will bypass the vlan
> check because promisc flag is set.  It will then try
> to get the table pointer and process the packet based
> on the table.  Since the table pointer is NULL, we oops.
> Catch this special condition in br_handle_vlan().
> 
> Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
> 
> * Changed to use kfree_skb() instead of kfree_skb_list() to
>   match the reset of bridge code.
> * Fix-up {} style.

Applied, thanks.
