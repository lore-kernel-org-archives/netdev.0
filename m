From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PACTH][IPV6] Introduce ip6_append_data
Date: Wed, 16 Apr 2003 21:03:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030416.210306.110472553.davem@redhat.com>
References: <20030417130231.179c7f00.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030417130231.179c7f00.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


You take direct page_address() of page, this is in general illegal.

Generally you must kmap the page to access it in the kernel as it may
be a HIGHMEM page.

I know that right now you control all the allocations with
alloc_page() and sk->allocation cannot currently allow highmem pages,
but let us not start with the assumptions right now :-)

As soon as you write udp6_sendfile() you will need to handle
this, that is for sure.
