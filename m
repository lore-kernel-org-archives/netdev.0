From: Paul Moore <pmoore@redhat.com>
Subject: Re: [Patch net-next 7/7] selinux: use generic union inet_addr
Date: Mon, 22 Jul 2013 16:36:07 -0400
Message-ID: <15803221.LSzpdzDYPS@sifl>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com> <1374476713-8838-8-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1374476713-8838-8-git-send-email-amwang@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, July 22, 2013 03:05:13 PM Cong Wang wrote:
> diff --git a/include/linux/lsm_audit.h b/include/linux/lsm_audit.h
> index 1cc89e9..db7c0d6 100644
> --- a/include/linux/lsm_audit.h
> +++ b/include/linux/lsm_audit.h
> @@ -21,6 +21,7 @@
>  #include <linux/path.h>
>  #include <linux/key.h>
>  #include <linux/skbuff.h>
> +#include <net/inet_addr.h>
> 
>  struct lsm_network_audit {
>  	int netif;
> @@ -28,16 +29,8 @@ struct lsm_network_audit {
>  	u16 family;
>  	__be16 dport;
>  	__be16 sport;
> -	union {
> -		struct {
> -			__be32 daddr;
> -			__be32 saddr;
> -		} v4;
> -		struct {
> -			struct in6_addr daddr;
> -			struct in6_addr saddr;
> -		} v6;
> -	} fam;
> +	union inet_addr saddr;
> +	union inet_addr daddr;
>  };
> 
>  /* Auxiliary data to use in generating the audit record. */
> @@ -83,9 +76,6 @@ struct common_audit_data {
>  	}; /* per LSM data pointer union */
>  };
> 
> -#define v4info fam.v4
> -#define v6info fam.v6

These changes are going to affect Smack as well.  You either need to respin 
this patch to include all of the LSMs (Smack should be the only other affected 
LSM) or add a new patch to the patchset.

-- 
paul moore
security and virtualization @ redhat

