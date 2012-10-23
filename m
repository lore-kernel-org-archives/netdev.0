From: Serge Hallyn <serge.hallyn@canonical.com>
Subject: Re: [PATCH v6 06/10] glge driver: rename internal SEM_SET macro to
 SEM_INIT
Date: Tue, 23 Oct 2012 11:32:59 -0500
Message-ID: <20121023163259.GE9755@sergelap>
References: <20121015155800.28348.23561.stgit@localhost.localdomain>
 <20121015160006.28348.79520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com,
	will.deacon@arm.com, dhowells@redhat.com, manfred@colorfullife.com,
	hughd@google.com, jmorris@namei.org, mtk.manpages@gmail.com,
	kosaki.motohiro@jp.fujitsu.com, paulmck@linux.vnet.ibm.com,
	sds@tycho.nsa.gov, devel@openvz.org, a.p.zijlstra@chello.nl,
	cmetcalf@tilera.com, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, viro@zeniv.linux.org.uk,
	eparis@parisplace.org, tglx@linutronix.de,
	jitendra.kalsaria@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, ebiederm@xmission.com,
	casey@schaufler-ca.com
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121015160006.28348.79520.stgit@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Stanislav Kinsbursky (skinsbursky@parallels.com):
> The reason for shit patch is that SET_SET is desired to be a part of new part
> of API of IPC sys_semctl() system call.
> The name itself for IPC is quite natural, because all linux-specific commands
> names for IPC system calls are originally created by replacing "IPC_" part by
> "SEM_"("MSG_", "SHM_") part.
> So, I'm hoping, that this change doesn't really matters for "QLogic qlge NIC

Can't speak for the driver maintainer, but it does look sane.

Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>

> HBA Driver" developers, since it's just an internal define.
> ---
>  drivers/net/ethernet/qlogic/qlge/qlge.h      |    4 ++--
>  drivers/net/ethernet/qlogic/qlge/qlge_main.c |   16 ++++++++--------
>  2 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
> index a131d7b..6f46ea5 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge.h
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge.h
> @@ -347,10 +347,10 @@ enum {
>  enum {
>  	/*
>  	 * Example:
> -	 * reg = SEM_XGMAC0_MASK | (SEM_SET << SEM_XGMAC0_SHIFT)
> +	 * reg = SEM_XGMAC0_MASK | (SEM_INIT << SEM_XGMAC0_SHIFT)
>  	 */
>  	SEM_CLEAR = 0,
> -	SEM_SET = 1,
> +	SEM_INIT = 1,
>  	SEM_FORCE = 3,
>  	SEM_XGMAC0_SHIFT = 0,
>  	SEM_XGMAC1_SHIFT = 2,
> diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> index b262d61..cfb0f62 100644
> --- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> +++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
> @@ -109,28 +109,28 @@ static int ql_sem_trylock(struct ql_adapter *qdev, u32 sem_mask)
>  
>  	switch (sem_mask) {
>  	case SEM_XGMAC0_MASK:
> -		sem_bits = SEM_SET << SEM_XGMAC0_SHIFT;
> +		sem_bits = SEM_INIT << SEM_XGMAC0_SHIFT;
>  		break;
>  	case SEM_XGMAC1_MASK:
> -		sem_bits = SEM_SET << SEM_XGMAC1_SHIFT;
> +		sem_bits = SEM_INIT << SEM_XGMAC1_SHIFT;
>  		break;
>  	case SEM_ICB_MASK:
> -		sem_bits = SEM_SET << SEM_ICB_SHIFT;
> +		sem_bits = SEM_INIT << SEM_ICB_SHIFT;
>  		break;
>  	case SEM_MAC_ADDR_MASK:
> -		sem_bits = SEM_SET << SEM_MAC_ADDR_SHIFT;
> +		sem_bits = SEM_INIT << SEM_MAC_ADDR_SHIFT;
>  		break;
>  	case SEM_FLASH_MASK:
> -		sem_bits = SEM_SET << SEM_FLASH_SHIFT;
> +		sem_bits = SEM_INIT << SEM_FLASH_SHIFT;
>  		break;
>  	case SEM_PROBE_MASK:
> -		sem_bits = SEM_SET << SEM_PROBE_SHIFT;
> +		sem_bits = SEM_INIT << SEM_PROBE_SHIFT;
>  		break;
>  	case SEM_RT_IDX_MASK:
> -		sem_bits = SEM_SET << SEM_RT_IDX_SHIFT;
> +		sem_bits = SEM_INIT << SEM_RT_IDX_SHIFT;
>  		break;
>  	case SEM_PROC_REG_MASK:
> -		sem_bits = SEM_SET << SEM_PROC_REG_SHIFT;
> +		sem_bits = SEM_INIT << SEM_PROC_REG_SHIFT;
>  		break;
>  	default:
>  		netif_alert(qdev, probe, qdev->ndev, "bad Semaphore mask!.\n");
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
