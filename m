From: Solar Designer <solar@openwall.com>
Subject: Re: [PATCH] net: ipv4: add IPPROTO_ICMP socket kind
Date: Tue, 12 Apr 2011 09:06:59 +0400
Message-ID: <20110412050659.GA14129@openwall.com>
References: <20110409101514.GA4262@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Kees Cook <kees.cook@canonical.com>,
	Dan Rosenberg <dan.j.rosenberg@gmail.com>,
	Eugene Teo <eugene@redhat.com>,
	Nelson Elhage <nelhage@ksplice.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Pekka Savola <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mother.openwall.net ([195.42.179.200]:53177 "HELO
	mother.openwall.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750971Ab1DLFOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 01:14:05 -0400
Content-Disposition: inline
In-Reply-To: <20110409101514.GA4262@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 09, 2011 at 02:15:14PM +0400, Vasiliy Kulikov wrote:
> This patch adds IPPROTO_ICMP socket kind.  It makes it possible to send
> ICMP_ECHO messages and receive the corresponding ICMP_ECHOREPLY messages
> without any special privileges.  In other words, the patch makes it
> possible to implement setuid-less and CAP_NET_RAW-less /bin/ping.  In
> order not to increase the kernel's attack surface (in case of
> vulnerabilities in the newly added code), the new functionality is
> disabled by default, but is enabled at bootup by supporting Linux
> distributions, optionally with restriction to a group or a group range
...
> For Openwall GNU/*/Linux it is the last step on the road to the
> setuid-less distro.

More correctly, it _was_ the last step - we've already taken it, so a
revision of the patch (against OpenVZ/RHEL5 kernels) is currently in use.

We would really like this accepted into mainline, which is why Vasiliy
spends extra effort to keep the patch updated to current mainline
kernels and re-test it.  If there are any comments/concerns/objections,
we'd be happy to hear those.

> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Acked-by: Solar Designer <solar@openwall.com>

>  include/net/netns/ipv4.h   |    2 +
>  include/net/ping.h         |   69 ++++
>  net/ipv4/Kconfig           |   21 +
>  net/ipv4/Makefile          |    1 +
>  net/ipv4/af_inet.c         |   36 ++
>  net/ipv4/icmp.c            |   14 +-
>  net/ipv4/ping.c            |  933 ++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/sysctl_net_ipv4.c |   90 +++++
>  8 files changed, 1165 insertions(+), 1 deletions(-)

Thanks,

Alexander
