From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: Prevent insertion of FDB entry
 with disallowed vlan
Date: Fri, 30 May 2014 15:48:57 -0700 (PDT)
Message-ID: <20140530.154857.23436038195529720.davem@davemloft.net>
References: <1401084953-10135-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1401084953-10135-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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
Date: Mon, 26 May 2014 15:15:53 +0900

> br_handle_local_finish() is allowing us to insert an FDB entry with
> disallowed vlan. For example, when port 1 and 2 are communicating in
> vlan 10, and even if vlan 10 is disallowed on port 3, port 3 can
> interfere with their communication by spoofed src mac address with
> vlan id 10.
> 
> Note: Even if it is judged that a frame should not be learned, it should
> not be dropped because it is destined for not forwarding layer but higher
> layer. See IEEE 802.1Q-2011 8.13.10.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

In reference to Vlad's suggestion to try to reuse the logic of the
existing br_allowed_ingress() function, I don't think that's so
easy.

As stated already, it drops packets whilst we don't want that here.

Another difference is that it does vlan_untag(), which we also do
not want here.

Let's just stay with this version of the fix, Vlad if you're OK with
that can you please give your ACK?  Thanks.
