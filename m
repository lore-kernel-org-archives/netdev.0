From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/3] Namespaceify tcp keepalive machinery
Date: Thu, 07 Jan 2016 15:38:13 -0600
Message-ID: <87twmpax4q.fsf@x220.int.ebiederm.org>
References: <1452177525-13244-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	fan.du@intel.com, kaber@trash.net, jmorris@namei.org,
	alexander.h.duyck@redhat.com, kuznet@ms2.inr.ac.ru,
	operations@siteground.com
To: Nikolay Borisov <kernel@kyup.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452177525-13244-1-git-send-email-kernel@kyup.com> (Nikolay
	Borisov's message of "Thu, 7 Jan 2016 16:38:42 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nikolay Borisov <kernel@kyup.com> writes:

> The following patch series enables the tcp keepalive mechanism
> to be configured per net namespace. This is especially useful
> if you have multiple containers hosted on one node and one of 
> them is under DoS-  in such situations one thing which could 
> be done is to configure the tcp keepalive settings such that 
> connections for that particular container are being reset 
> faster.
>
> Another scenario where not being able to control those knob
> comes per container is problematic is occurs the value of 
> net.netfilter.nf_conntrack_tcp_timeout_established is set
> below the keepalive interval, in such situations the server won't 
> send an RST packet resulting in applications not trying to 
> reconnect and stale connection waiting. Changing the global 
> keepalive value is a possible solution but it might interfere
> with other containers. 
>
> The three patches gradually convert each of the affected knobs
> to be per netns. I thought it would be easier for review than 
> put everything in one patch. If people deem it more appropriate 
> to squash everything in one patch (maybe after review) I'd
> be more than happy to do it. 
>
> The patches have been compile-tested on 4.4 and functionally 
> tested on 3.12 and they work as expected. 
>
> These are based off 4.4-rc8

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

I took a quick skim and there appears to be nothing scary in your
patches and the separation of the patches did make the review easy.

All of the knobs are already per socket with a global default.  Moving
that global to be per network namespace appears straight forward in
your patches.

> Nikolay Borisov (3):
>   ipv4: Namespaceify tcp_keepalive_time sysctl knob
>   ipv4: Namespecify tcp_keepalive_probes sysctl knob 
>   ipv4: Namespecify the tcp_keepalive_intvl sysctl knob
>
>  include/net/netns/ipv4.h   |  4 ++++
>  include/net/tcp.h          | 15 +++++++++------
>  net/ipv4/sysctl_net_ipv4.c | 42 +++++++++++++++++++++---------------------
>  net/ipv4/tcp_ipv4.c        |  4 ++++
>  net/ipv4/tcp_timer.c       |  3 ---
>  5 files changed, 38 insertions(+), 30 deletions(-)
