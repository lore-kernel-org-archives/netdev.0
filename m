From: Amin Azez <azez@ufomechanic.net>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Fri, 22 Jul 2005 09:34:49 +0100
Message-ID: <42E0AFA9.6090308@ufomechanic.net>
References: <1121970035.5904.6.camel@notepaq>	<20050721.131250.55509013.davem@davemloft.net>	<1121982131.5886.2.camel@notepaq>
	<20050721.152941.56567834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050721.152941.56567834.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> This probably has nothing to do with why the patch doesn't
> work for you, but the transformation of "incoming" to a "u8"
> from an "int" is not fully correct, because hci_sock.c
> does this:
> 
> 	put_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, sizeof(int), &bt_cb(skb)->incoming);
> 

These things always scare me, why do folk litter code with sly knowledge
of the size of struct members that may and do change?

Why don't people do:

put_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, sizeof(bt_cb(skb)->incoming),
&bt_cb(skb)->incoming);

Or even better, use a macro to capture the semantics

#define put_struct_msg(msg, S, H, ITEM) \
 put_cmsg((msg),(S),(H),sizeof(ITEM),&(ITEM))

then do:
put_struct_cmsg(msg, SOL_HCI, HCI_CMSG_DIR, bt_cb(skb)->incoming);


It is true that macros can be over-used to create a meta-language and
uber-api, but this case saves no end of trouble, surely it is what
macros are for?

Sam
