From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH v7 17/21] IB/hns: Add QP operations support
Date: Fri, 13 May 2016 17:52:04 -0400
Message-ID: <bf001e31-982a-c51d-782e-81ee19f9de09@redhat.com>
References: <1462849483-67927-1-git-send-email-oulijun@huawei.com>
 <1462849483-67927-18-git-send-email-oulijun@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="jveuGMgECj8uME3rkPil7mqHGxXbvOcqB"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1462849483-67927-18-git-send-email-oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jveuGMgECj8uME3rkPil7mqHGxXbvOcqB
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 05/09/2016 11:04 PM, Lijun Ou wrote:
> +int __hns_roce_cmd(struct hns_roce_dev *hr_dev, u64 in_param, u64 *out=
_param,
> +		   unsigned long in_modifier, u8 op_modifier, u16 op,
> +		   unsigned long timeout);
> +
> +/* Invoke a command with no output parameter */
> +static inline int hns_roce_cmd(struct hns_roce_dev *hr_dev, u64 in_par=
am,
> +			       unsigned long in_modifier, u8 op_modifier,
> +			       u16 op, unsigned long timeout)
> +{
> +	return __hns_roce_cmd(hr_dev, in_param, NULL, in_modifier,
> +			      op_modifier, op, timeout);
> +}
> +
> +/* Invoke a command with an output mailbox */
> +static inline int hns_roce_cmd_box(struct hns_roce_dev *hr_dev, u64 in=
_param,
> +				   u64 out_param, unsigned long in_modifier,
> +				   u8 op_modifier, u16 op,
> +				   unsigned long timeout)
> +{
> +	return __hns_roce_cmd(hr_dev, in_param, &out_param, in_modifier,
> +			      op_modifier, op, timeout);
> +}

This will make people scratch their head in the future.  You are using
two commands to map to one command without there being any locking
involved.  The typical convention for routine_1() -> __routine_1() is
that the __ version requires that it be called while locked, and the
version without a __ does the locking before calling it.  That way a
used can always know if they aren't currently holding the appropriate
lock, then they6 call routine_1() and if they are, they call
__routine_1() to avoid a deadlock.  I would suggest changing the name of
__hns_roce_cmd to hns_roce_cmd_box and completely remove the existing
hns_roce_cmd_box inline, and then change the hns_roce_cmd() inline to
directly call hns_roce_cmd_box() which will then select between
event/poll command sends.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--jveuGMgECj8uME3rkPil7mqHGxXbvOcqB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXNkyEAAoJELgmozMOVy/dfGkP/1eSnxCzxbLrms/NZCBfALNB
BHt5TYgcJF8qkQqirubFt6YS51zJdOTO5xMqyv3ySOLMggG6fVRVjWoC6WxRGZtT
oFSNiv8JBgpYG0w7e5u49jdaDQT33hql6ndpfg+vWO3WXT7YAk+mS0+9NFARFbmC
QqoZTCh1lb3Bg3/fwynPY7SdzUfOt98R+nLUGOpgqssNGG0pKEUXbZbC3T2bd/P+
p2E+FlmBaJy/5H2evRcQ3C4bC8nSQVhvhocEQTh2DCF80+wa0Yoc271yZgSSFXy3
/mUdD4tgOAyTUOmbrCNMwXzXIgbMiw+h8QB74bN2D1HqLfKTyStkPwrK/Nny9t44
8TcmiSL8RzTYc7X2jWuZKp6EE93fiNF1cGoT8fEY5Q0V08Ll9YaNiIX1beUncjGq
iC0Zdbz9z17jY0TAPWQsbgRzhFnlnxC7xQ8ZYuWQnU04ZqSHnANznzFVEZxEPnu7
M1oFYL1GO/jPuNTv3XV12xOPkAuL4xrn2NGkf25FNSCkBr9vQRkwmPBeQ77vVkuU
Xvk/j7Mv0reqvmbVLPKVuit1fZl1xfJ765cyjKVpaiDoAS3tesOZhwcc8h81ycdM
Rk+iwxXI6U7mt6V897bfCHrwkdKbk2plXUqdGE32cgsGJrxJkLLnERHFhMd2lXGs
4icFUfNSvSaAckG60JYe
=CRdL
-----END PGP SIGNATURE-----

--jveuGMgECj8uME3rkPil7mqHGxXbvOcqB--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
