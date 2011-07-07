From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V8 2/4 net-next] skbuff: skb supports zero-copy buffers
Date: Thu, 07 Jul 2011 04:01:49 -0700 (PDT)
Message-ID: <20110707.040149.441417258943576903.davem@davemloft.net>
References: <1309990932.10209.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mashirle@us.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1309990932.10209.19.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shirley Ma <mashirle@us.ibm.com>
Date: Wed, 06 Jul 2011 15:22:12 -0700

> +			while (head) {
> +				put_page(head);
> +				head = (struct page *)head->private;
> +			}

Looks like you might be referencing the page after it's
release here.  I think you need something like:

			while (head) {
				struct page *next = (struct page *)head->private;
				put_page(head);
				head = next;
			}
