From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 09:40:56 -0700
Message-ID: <1460652056.10638.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
	 <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160414151813.GE3715@orbyte.nwl.cc>
	 <alpine.LNX.2.00.1604141733250.27368@cbobk.fhfr.pm>
	 <1460648680.10638.47.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160414162229.GF3715@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jikos@kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160414162229.GF3715@orbyte.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-14 at 18:22 +0200, Phil Sutter wrote:

> And those being invisible can be overridden using 'tc qd add', right?
> AFAIR they're not listed because they don't properly register, so the
> system doesn't care to override them. In this case we could change all
> classful qdiscs to restore the default qdisc if a leaf qdisc is being
> deleted instead of noop (which is probably not what the user wants
> anyway).

Even if they properly register, they are not visible.

Take a look at
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=95dc19299f741c986227ec33e23cbf9b3321f812

for some context.

When a default pfifo is created on say a HTB class, you do not see it by
default in a dump.

If you have 100 HTB classes, HTB created 100 pfifo just fine, and it
works, unless an admin tries to delete them maybe ;)
