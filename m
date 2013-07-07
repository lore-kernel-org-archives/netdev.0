From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: pull on receive skb may need to happen
 earlier
Date: Sat, 06 Jul 2013 18:10:03 -0700 (PDT)
Message-ID: <20130706.181003.1511214773924103305.davem@davemloft.net>
References: <20130704150137.GW7483@zion.uk.xensource.com>
	<51D6AED902000078000E2EA9@nat28.tlf.novell.com>
	<20130705145319.GB9050@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: JBeulich@suse.com, ian.campbell@citrix.com, g.w.kant@hunenet.nl,
	xen-devel@lists.xen.org, netdev@vger.kernel.org,
	stable@vger.kernel.org
To: wei.liu2@citrix.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130705145319.GB9050@zion.uk.xensource.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Liu <wei.liu2@citrix.com>
Date: Fri, 5 Jul 2013 15:53:19 +0100

> You seem to be altering the behavior of the original code, because in
> your patch the skb->len is incremented before use, while in the original
> code (which calls skb_headlen in handle_incoming_packet) the skb->len is
> correctly set.

Indeed, I think you're right.

Because __pskb_pull_tail() decrements the number of bytes pulled
from skb->data_len, it won't be accounted for in skb->len
