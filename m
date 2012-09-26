From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH v5 01/10] ipc: remove forced assignment of selected
 message
Date: Wed, 26 Sep 2012 12:37:18 -0500
Message-ID: <20120926173718.GA30620@sergelap>
References: <20120919160430.11254.86848.stgit@localhost6.localdomain6>
 <20120919160531.11254.48182.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, manfred@colorfullife.com,
	a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	will.deacon@arm.com, linux-kernel@vger.kernel.org,
	cmetcalf@tilera.com, jmorris@namei.org, linux-driver@qlogic.com,
	linux-security-module@vger.kernel.org, hughd@google.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	james.l.morris@oracle.com, catalin.marinas@arm.com,
	casey@schaufler-ca.com, eparis@parisplace.org, sds@tycho.nsa.gov,
	jitendra.kalsaria@qlogic.com, devel@openvz.org
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120919160531.11254.48182.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Stanislav Kinsbursky (skinsbursky@parallels.com):
> This is a cleanup patch. The assignment is redundant.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> ---
>  ipc/msg.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/ipc/msg.c b/ipc/msg.c
> index 7385de2..f3bfbb8 100644
> --- a/ipc/msg.c
> +++ b/ipc/msg.c
> @@ -787,7 +787,6 @@ long do_msgrcv(int msqid, long *pmtype, void __user *mtext,
>  			    !security_msg_queue_msgrcv(msq, walk_msg, current,
>  						       msgtyp, mode)) {
>  
> -				msg = walk_msg;
>  				if (mode == SEARCH_LESSEQUAL &&
>  						walk_msg->m_type != 1) {
>  					msg = walk_msg;

Perhaps your tree is different from mine, but it looks to me like it would
be simpler to remove the 'msg = walk_msg' from both the 'if' and 'else',
and keep them above the if/else?
