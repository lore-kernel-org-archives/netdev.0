From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: FW: [REGRESSION] be2net: not work in 3.12
Date: Tue, 12 Nov 2013 11:13:36 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C26A40D0D@CMEXMB1.ad.emulex.com>
References: <20131112010807.GA6044@yanx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Guo Chao (yan@linux.vnet.ibm.com)" <yan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:55704 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab3KLLNi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 06:13:38 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Guo Chao [mailto:yan@linux.vnet.ibm.com]
> 
> Hello:
> 
>   After commit 92bf14ab(be2net: refactor be_get_resources() code),
> be2net is not working on a PowerPC machine.
> 
> [   72.653560] be2net 0001:01:00.0: Could not use PCIe error reporting
> [   73.933727] be2net 0001:01:00.0: Max: txqs 8, rxqs 8, rss 7, eqs 0,
> vfs 20
> [   73.933794] be2net 0001:01:00.0: Max: uc-macs 64, mc-macs 64, vlans 8
> [   73.933875] be2net 0001:01:00.0: MSIx enable failed
> [   73.973728] be2net 0001:01:00.0: created 0 TX queue(s)
> [   73.973795] be2net 0001:01:00.0: created -1 RSS queue(s) and 1
> default RX queue
> [   74.013735] be2net 0001:01:00.0: opcode 12-1 failed:status 3-11
> [   74.013811] be2net 0001:01:00.0: queue_setup failed
> [   74.013949] be2net 0001:01:00.0: Emulex OneConnect(Lancer)
> initialization failed
> [   74.014018] be2net: probe of 0001:01:00.0 failed with error -1
> 
> This change makes it work:
> 
> --- a/drivers/net/ethernet/emulex/benet/be_cmds.c
> +++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
> @@ -3187,6 +3187,8 @@ static void be_copy_nic_desc(struct be_resources
> *res,
>         res->max_rss_qs = le16_to_cpu(desc->rssq_count);
> 	res->max_rx_qs = le16_to_cpu(desc->rq_count);
> 	res->max_evt_qs = le16_to_cpu(desc->eq_count);
> +       if (res->max_evt_qs == 0)
> +               res->max_evt_qs = 8;
> 	/* Clear flags that driver is not interested in */
> 	res->if_cap_flags = le32_to_cpu(desc->cap_flags) &
> 				BE_IF_CAP_FLAGS_WANT;
> 
> Looks like firmware returns corrupted value. Can you fall back all
> limits to static ones if detected this?

Could you report the old (working) FW version and the new (broken) FW version.
This clearly seems like a FW bug and I think it should be fixed in FW rather than
the driver.

thanks,
-Sathya
