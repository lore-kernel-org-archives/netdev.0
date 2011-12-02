From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH net-next V0 19/21] mlx4_core: Modify driver initialization
 flow to accommodate SRIOV for Ethernet
Date: Fri, 2 Dec 2011 09:51:06 -0800
Message-ID: <CAL1RGDV8LzSOei=aQW7VXUP=G+9qdO+Y4eKZu8mBuHJuUp8UuQ@mail.gmail.com>
References: <4ED8A636.40901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4ED8A636.40901-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> =A0#ifdef CONFIG_PCI_IOV
> +
> +static int sr_iov;
> +module_param(sr_iov, int, 0444);
> +MODULE_PARM_DESC(sr_iov, "enable #sr_iov functions if sr_iov > 0");
> +
> +static int probe_vf;
> +module_param(probe_vf, int, 0444);
> +MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (sr_=
iov > 0)");
> +
> =A0int mlx4_log_num_mgm_entry_size =3D 10;
> =A0module_param_named(log_num_mgm_entry_size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mlx4_log_num_mgm_entry=
_size, int, 0444);
> @@ -85,24 +95,30 @@ MODULE_PARM_DESC(log_num_mgm_entry_size, "log mgm=
 size, that defines the num"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 " log_num_mgm_entry_size <=3D 12");
>
> =A0#else /* CONFIG_PCI_IOV */
> +static int sr_iov;
> +#define probe_vf 0
> =A0int mlx4_log_num_mgm_entry_size =3D 9;
> =A0#endif /* CONFIG_PCI_IOV */

I don't think it's a good idea to put module parameters inside an
#ifdef.  Then depending on the
kernel config someone compiles with, their modprobe.conf may or may not=
 break.

> +static int port_type_array[2] =3D {1, 1};
> +static int arr_argc =3D 2;
> +module_param_array(port_type_array, int, &arr_argc, 0444);
> +MODULE_PARM_DESC(port_type_array, "Array of port types: IB by defaul=
t");

Is this really the best way to pass this in?  What if I have two
adapters, and I want to use
the first one for IB and the second for ethernet?  (Which doesn't
sound like a particularly
obscure config)

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
