From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v6 04/10] ipc: add new SHM_SET command for sys_shmctl()
 call
Date: Mon, 15 Oct 2012 20:00:28 +0100
Message-ID: <1350327628.2819.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121015155800.28348.23561.stgit@localhost.localdomain>
	 <20121015155956.28348.36765.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <dhowells@redhat.com>,
	<manfred@colorfullife.com>, <hughd@google.com>,
	<jmorris@namei.org>, <mtk.manpages@gmail.com>,
	<kosaki.motohiro@jp.fujitsu.com>, <paulmck@linux.vnet.ibm.com>,
	<sds@tycho.nsa.gov>, <devel@openvz.org>, <a.p.zijlstra@chello.nl>,
	<cmetcalf@tilera.com>, <linux-driver@qlogic.com>,
	<ron.mercer@qlogic.com>, <viro@zeniv.linux.org.uk>,
	<eparis@parisplace.org>, <tglx@linutronix.de>,
	<jitendra.kalsaria@qlogic.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-security-module@vger.kernel.org>, <ebiederm@xmission.com>,
	<casey@schaufler-ca.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121015155956.28348.36765.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-10-15 at 19:59 +0400, Stanislav Kinsbursky wrote:
> New SHM_SET command will be interpreted exactly as IPC_SET, but also will
> update key, cuid and cgid values. IOW, it allows to change existent key value.
> The fact, that key is not used is checked before update. Otherwise -EEXIST is
> returned.
[...]
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
[...]
> @@ -759,6 +763,10 @@ static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
>  	case IPC_RMID:
>  		do_shm_rmid(ns, ipcp);
>  		goto out_up;
> +	case SHM_SET:
> +		err = ipc_update_key(&shm_ids(ns), &shmid64.shm_perm, ipcp);
> +		if (err)
> +			break;
[...]

Please add /* fall through */ here, and in the similar cases in patches
5 and 7, to make clear that it's deliberate.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
