From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy poll
Date: Wed, 21 Aug 2013 06:53:08 -0700
Message-ID: <1377093188.4226.108.camel@edumazet-glaptop>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-08-21 at 13:39 +0300, Eliezer Tamir wrote:

> 
> Instead of remembering the napi_id for all the sockets in an epoll,
> we only track the first socket we see with any unique napi_id.
> The rational for this is that while there may be many thousands of
> sockets tracked by a single epoll, we expect to only see a handful
> of unique napi_ids in most cases.

This looks buggy assumption to me.

We use epoll() with in the order of millions of fds per epoller, and
typically one napi_id per cpu.

With your model, we would have to use nr_cpu epollers and make sure that
sockets are properly placed on those epollers by their napi_ids.
