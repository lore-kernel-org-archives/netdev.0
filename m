From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] kfree_skb() bug in 2.4.22
Date: Wed, 08 Oct 2003 09:09:48 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F840C9C.9050704@pobox.com>
References: <1065617075.1514.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, coreteam@netfilter.org,
	netfilter@lists.netfilter.org, akpm@zip.com.au, davem@redhat.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@intercode.com.au,
	yoshfuji@linux-ipv6.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Tobias DiPasquale <toby@cbcg.net>
In-Reply-To: <1065617075.1514.29.camel@localhost>
List-Id: netdev.vger.kernel.org

Tobias DiPasquale wrote:
> Hi all,
> 
> I was debugging one of my iptables/netfilter modules yesterday and I
> came across this bug in kfree_skb(). One of my functions returns a
> struct skbuff * on success and NULL on failure. When it failed, the code
> calling said function attempted to free the struct skbuff *, which at
> that point was NULL. This produced a kernel panic. I investigated the
> problem and found that, not only should I be checking for a NULL pointer
> when freeing the struct skbuff *, but the actual cause of the panic was
> because kfree_skb() and kfree_skb_fast() do not check for skb==NULL,
> either. They immediately attempt to dereference the users field of the
> struct skbuff * in order to decrement that reference counter. 


I would prefer that you fix your code instead, to not pass NULL to 
kfree_skb()...

