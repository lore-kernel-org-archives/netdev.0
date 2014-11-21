From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Fri, 21 Nov 2014 07:01:25 -0800
Message-ID: <1416582085.8629.98.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CA+55aFyQR2gOzEDROcWFcQzLvTjOxyJRjFJXJ03JB5knd-Gsgg@mail.gmail.com>
	 <20141119.161744.1661940121298888832.davem@davemloft.net>
	 <20141119213006.GE7996@ZenIV.linux.org.uk>
	 <20141119.165340.2162829993279387495.davem@davemloft.net>
	 <20141120214753.GR7996@ZenIV.linux.org.uk>
	 <1416520542.8629.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141120222506.GS7996@ZenIV.linux.org.uk>
	 <1416524035.8629.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141121084956.GT7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141121084956.GT7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-11-21 at 08:49 +0000, Al Viro wrote:

> Another thing is tcp_sendmsg_fastopen() and tcp_send_rcvq().  The latter
> should just use copy_from_iter() instead of memcpy_from_iovec(), the former
> is dealt with by making tcp_send_syn_data() use the same copy_from_iter()
> instead of memcpy_from_iovecend().

Well, another problem I already mentioned is that tcp_send_rcvq() does a
single alloc_skb() with @size directly coming from user space. This
certainly can try allocation of dozen of Megabytes.

Not good.
