From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] drivers/net: Use RCU_INIT_POINTER(x, NULL) in tun.c
Date: Mon, 24 Mar 2014 05:53:58 -0700
Message-ID: <1395665638.12610.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395599552-7486-1-git-send-email-monamagarwal123@gmail.com>
	 <20140323194113.GA13633@redhat.com>
	 <1395604457.9117.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140323213349.GA8832@redhat.com>
	 <20140323221256.GG4405@linux.vnet.ibm.com>
	 <20140324050939.GB8832@redhat.com>
	 <1395638727.9117.55.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140324062225.GA22338@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Monam Agarwal <monamagarwal123@gmail.com>, davem@davemloft.net,
	jasowang@redhat.com, xemul@parallels.com, wuzhy@linux.vnet.ibm.com,
	therbert@google.com, yamato@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140324062225.GA22338@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-24 at 08:22 +0200, Michael S. Tsirkin wrote:

> What happens if someone then changes that NULL to something else?
> Things will start to break in subtle way, won't they?

Sure. As anything else can break when/if using wrong API or in any
change. Particularly in RCU protected code. Even a kzalloc() can be
buggy.

Note that smp_wmb() is hardly expensive in all these paths,
so thats why I do not care anymore asking guys using RCU_INIT_POINTER(x,
NULL) instead of rcu_assign_pointer() as I used to.

When doing tree wide change (like in commit 2cfa5a0471fef43), I usually
not do a dumb one, I take the time to read the code and check it for
defects.

I do not remember what kind of compiler warnings we had 3 years ago,
But I do not want to spend more cycles on this subject...
