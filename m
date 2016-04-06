From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Wed, 6 Apr 2016 14:37:30 -0700
Message-ID: <5705819A.3030809@schaufler-ca.com>
References: <cover.1459934322.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <cover.1459934322.git.pabeni@redhat.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/6/2016 2:51 AM, Paolo Abeni wrote:
> Currently, selinux always registers iptables POSTROUTING hooks regarless of
> the running policy needs for any action to be performed by them.
>
> Even the socket_sock_rcv_skb() is always registered, but it can result in a no-op
> depending on the current policy configuration.
>
> The above invocations in the kernel datapath are cause of measurable
> overhead in networking performance test.
>
> This patch series adds explicit notification for netlabel status change 
> (other relevant status change, like xfrm and secmark, are already notified to
> LSM) and use this information in selinux to register the above hooks only when
> the current status makes them relevant, deregistering them when no-op
>
> Avoiding the LSM hooks overhead, in netperf UDP_STREAM test with small packets,
> gives about 5% performance improvement on rx and about 8% on tx.
>
> Paolo Abeni (2):
>   security: add hook for netlabel status change notification
>   selinux: implement support for dynamic net hook [de-]registration
>
>  include/linux/lsm_hooks.h           |  6 ++++
>  include/linux/security.h            |  5 +++
>  net/netlabel/netlabel_cipso_v4.c    |  8 +++--
>  net/netlabel/netlabel_unlabeled.c   |  5 ++-
>  security/security.c                 |  7 ++++
>  security/selinux/hooks.c            | 72 +++++++++++++++++++++++++++++++------
>  security/selinux/include/security.h |  1 +
>  security/selinux/ss/services.c      |  1 +
>  security/selinux/xfrm.c             |  4 +++
>  9 files changed, 96 insertions(+), 13 deletions(-)
>
Is there a patch 1/2?

