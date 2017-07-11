From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 V3 1/4] rdma: Add basic infrastructure for RDMA
 tool
Date: Tue, 11 Jul 2017 10:23:14 +0300
Message-ID: <20170711072314.GU1528@mtr-leonro.local>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-2-leon@kernel.org>
 <20170710074717.GB1853@nanopsycho>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Ui7Ivv9AiAUGhDAy"
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170710074717.GB1853@nanopsycho>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Ui7Ivv9AiAUGhDAy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 10, 2017 at 09:47:17AM +0200, Jiri Pirko wrote:
> Tue, Jul 04, 2017 at 09:55:38AM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
> >From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> >RDMA devices are cross-functional devices from one side,
> >but very tailored for the specific markets from another.
> >
> >Such diversity caused to spread of RDMA related configuration
> >across various tools, e.g. devlink, ip, ethtool, ib specific and
> >vendor specific solutions.
> >
> >This patch adds ability to fill device and port information
> >by reading RDMA netlink.
> >
> >Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
> [...]
>
>
> >+
> >+int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
> >+{
> >+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
> >+	struct dev_map *dev_map;
> >+	struct rdma *rd = data;
> >+	const char *dev_name;
> >+
> >+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
> >+	if (!tb[RDMA_NLDEV_ATTR_DEV_NAME] || !tb[RDMA_NLDEV_ATTR_DEV_INDEX])
> >+		return MNL_CB_ERROR;
> >+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
> >+		pr_err("This tool doesn't support switches yet\n");
> >+		return MNL_CB_ERROR;
> >+	}
> >+
> >+	dev_name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
> >+
> >+	dev_map = dev_map_alloc(dev_name);
> >+	if (!dev_map)
> >+		/* The main function will cleanup the allocations */
> >+		return MNL_CB_ERROR;
> >+	list_add_tail(&dev_map->list, &rd->dev_map_list);
> >+
> >+	dev_map->num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
> >+	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
> >+
> >+	return MNL_CB_OK;
> >+}
> >+
> >+void rdma_free_devmap(struct rdma *rd)
> >+{
> >+	if(!rd)
> >+		return;
> >+	dev_map_cleanup(rd);
> >+}
> >+
> >+int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *cmds, const char *str)
>
> Sometimes the functions are prefixed "rd_", sometimes "rdma_".
> I think it would be nice to unify this with "rd_".

Right, I'll fix.

>
>
> >+{
> >+	const struct rdma_cmd *c;
> >+
> >+	/* First argument in objs table is default variant */
> >+	if (rd_no_arg(rd))
> >+		return cmds->func(rd);
> >+
> >+	for (c = cmds + 1; c->cmd; ++c) {
> >+		if (rd_argv_match(rd, c->cmd)) {
> >+			/* Move to next argument */
> >+			rd_arg_inc(rd);
> >+			return c->func(rd);
> >+		}
> >+	}
> >+
> >+	pr_err("Unknown %s '%s'.\n", str, rd_argv(rd));
> >+	return 0;
> >+}
> >+

--Ui7Ivv9AiAUGhDAy
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllkfOIACgkQ5GN7iDZy
WKdrpA//eOm6lYZ1x2nW3lPR7SRAVyPVHOctmzEDPvKkXQ8J2PPsNyis+dS7zeRE
ppzI3nzKV++L2t0bIdE4VJMpOZSWG+qobZooIeWUilMI+iy1yxHHl9MZf3TZga+g
TYLUXtmbRWpXJOhqo40tlE/XoyJsfv1Fe2rXk5Ms9X8I7TRhwflBxP/1QGiEsoo1
AhkYr1BnYIr1b6JKXZo2b5mzx0tq7gMtm7dPtsS9U+IzaaEArOFKi6rr6bpwx2xv
PHMmt2F6tQHWvWjidLIbcCfaR1K/VFYLYFtqkfWO2XubumEC0nSOGKYlpig9WEKD
KT3SLnGkxPqQwDncQdGiC8BkWkc/vhynDvkbV55+SRujJiatlQO4l/U6gZWRNNK9
vCnzEJMBlNNfN+04MTvR6JryYCu8wahO5Fm6wonDnDCWIm5o1mijhnD6PQSsWeQh
/u08T9fmoIIYw500cOmXiPaz3cA1rpiv4gtMSVBQFm309Y+XozDeqo++b3RdgCey
y3BaynC6IjfxJgLMPz+s+8Zz38SmPEQcLCCDwPsI0XyIFjfYTk7fNcgjGCJbKAfd
OyWk21pybR3LMiKbdYqUPKd/tUslk1gDKVZPcWf6sB2Llqssx1QlB5Rm/yhsckuG
/DR1LGpSG4xOyFmsYCXeaS2POai2MqOgM7Tr/IajbNo4o4bIPTk=
=SiET
-----END PGP SIGNATURE-----

--Ui7Ivv9AiAUGhDAy--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
