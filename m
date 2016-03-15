From: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH kernel] Revert "net/mlx4_core: Set UAR page size to
 4KB regardless of system page size"
Date: Tue, 15 Mar 2016 12:40:06 +0200
Message-ID: <CAJ3xEMhxUuQj+E00fa-tEKz+dVzDqFspC80Z=k7UPZpOP30H3g@mail.gmail.com>
References: <1458037148-4475-1-git-send-email-aik@ozlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Carol L Soto <clsoto-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>,
	Huy Nguyen <huyn-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1458037148-4475-1-git-send-email-aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2016 at 12:19 PM, Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org> wrote:
> This reverts commit 85743f1eb34548ba4b056d2f184a3d107a3b8917.
>
> Without this revert, POWER "pseries" KVM guests with a VF passed to a guest
> using VFIO fail to bring the driver up:
>
> mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
> mlx4_core: Initializing 0000:00:00.0
> mlx4_core 0000:00:00.0: enabling device (0000 -> 0002)
> mlx4_core 0000:00:00.0: Detected virtual function - running in slave mode
> mlx4_core 0000:00:00.0: Sending reset
> mlx4_core 0000:00:00.0: Sending vhcr0
> mlx4_core 0000:00:00.0: HCA minimum page size:512
> mlx4_core 0000:00:00.0: UAR size:4096 != kernel PAGE_SIZE of 65536
> mlx4_core 0000:00:00.0: Failed to obtain slave caps

> Both host and guest use 64K system pages.
>
> How to fix this properly? Thanks.

The commit message says:

"[..] Regarding backward compatibility in SR-IOV, if hypervisor has
this new code, the virtual OS must be updated. [...]"


Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
