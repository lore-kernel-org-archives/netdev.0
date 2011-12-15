From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Explicitly call tcp creation and init from
 memcontrol.c
Date: Fri, 16 Dec 2011 07:20:50 +0900
Message-ID: <20111216072050.4f49ac66.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323941672-14324-1-git-send-email-glommer@parallels.com>
	<1323941672-14324-3-git-send-email-glommer@parallels.com>
	<20111216011316.8d58bc8f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Glauber Costa <glommer@parallels.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	cgroups@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111216011316.8d58bc8f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Dec 2011 01:13:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 15 Dec 2011 13:34:32 +0400
> Glauber Costa <glommer@parallels.com> wrote:
> 
> > Walking the proto_list holds a read_lock, which prevents us from doing
> > allocations. Splitting the tcp create function into create + init is
> > good, but it is not enough since create_files will do allocations as well
> > (dentry ones, mostly).
> > 
> > Since this does not involve any protocol state, I propose we call the tcp
> > functions explicitly from memcontrol.c
> > 
> > With this, we lose by now the ability of doing cgroup memcontrol for
> > protocols that are loaded as modules. But at least the ones I have in mind
> > won't really need it (tcp_ipv6 being the only one, but it uses the same data
> > structures as tcp_ipv4). So I believe this to be the simpler solution to this
> > problem.
> > 
> > Signed-off-by: Glauber Costa <glommer@parallels.com>
> > CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> > CC: David S. Miller <davem@davemloft.net>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> Could you remake the patch onto the 'latest' linux-next ?
> As Dave mentioned, some bandaids are already applied and this patch hunks.

Applied patches by hand and did small test for hours.
seems good.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
