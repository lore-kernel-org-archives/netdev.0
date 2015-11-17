From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 4/5] sock, cgroup: add sock->sk_cgroup
Date: Tue, 17 Nov 2015 22:46:30 +0100
Message-ID: <564BA036.4000602@iogearbox.net>
References: <1447789240-29394-1-git-send-email-tj@kernel.org> <1447789240-29394-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com
To: Tejun Heo <tj@kernel.org>, davem@davemloft.net,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	lizefan@huawei.com, hannes@cmpxchg.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447789240-29394-5-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 11/17/2015 08:40 PM, Tejun Heo wrote:
...
> While it is possible to solve these issues from controller side by
> implementing hierarchical allowable ranges in both controllers, it
> would involve quite a bit of complexity in the controllers and further
> obfuscate network configuration as it becomes even more difficult to
> tell what's actually being configured looking from the network side.
> While not much can be done for v1 at this point, as membership
> handling is sane on cgroup v2, it'd be better to make cgroup matching
> behave like other network matches and classifiers than introducing
> further complications.
>
> In preparation, this patch adds sock->sk_cgroup which points to the
> associated cgroup.  A sock is associated on creation and stays
> associated to the same cgroup until freed; unfortunately, this ends up
> adding another cgroup field to struct sock on top of sk_cgrp_prioidx
> and sk_classid.  I tried to think of a way to somehow overload the
> existing fields but couldn't come up with a reasonable one.  For the
> longer term, the fields can be rearranged so that disabling prio and
> cls controllers reduce the size of the struct.

Do you see a way forward where the new behavior could be enabled f.e.
as an extra mount option (that long-term would be made default, while
deprecating the current behavior) on net_cls et al? There are various
more users at least on the net_cls side (nft and tc as well). Would be
really great, if sk_cgroup could abstract that somehow away for all of
them w/o adding a second version to all users.

Best,
Daniel
