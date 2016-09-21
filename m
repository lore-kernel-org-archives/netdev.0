From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [RFC v2 07/12] qedr: Add support for memory registeration verbs
Date: Wed, 21 Sep 2016 12:53:58 -0700
Message-ID: <a20d6d9f-4428-4a6c-fb2a-089fd95e6908@grimberg.me>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-8-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariel.Elior@cavium.com, Michal.Kalderon@cavium.com,
        Yuval.Mintz@cavium.com, rajesh.borundia@cavium.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: Ram Amrani <Ram.Amrani@cavium.com>, davem@davemloft.net,
        dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36646 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755894AbcIUTyG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 15:54:06 -0400
In-Reply-To: <1474367764-9555-8-git-send-email-Ram.Amrani@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +static int qedr_set_page(struct ib_mr *ibmr, u64 addr)
> +{
> +	struct qedr_mr *mr = get_qedr_mr(ibmr);
> +	struct qedr_pbl *pbl_table;
> +	struct regpair *pbe;
> +	u32 pbes_in_page;
> +
> +	if (unlikely(mr->npages == mr->info.pbl_info.num_pbes)) {
> +		DP_ERR(mr->dev, "qedr_set_page failes when %d\n", mr->npages);
> +		return -ENOMEM;
> +	}
> +
> +	DP_VERBOSE(mr->dev, QEDR_MSG_MR, "qedr_set_page pages[%d] = 0x%llx\n",
> +		   mr->npages, addr);
> +
> +	pbes_in_page = mr->info.pbl_info.pbl_size / sizeof(u64);
> +	pbl_table = mr->info.pbl_table + (mr->npages / pbes_in_page);
> +	pbe = (struct regpair *)pbl_table->va;
> +	pbe +=  mr->npages % pbes_in_page;
> +	pbe->lo = cpu_to_le32((u32)addr);
> +	pbe->hi = cpu_to_le32((u32)upper_32_bits(addr));
> +
> +	mr->npages++;
> +
> +	return 0;
> +}

Looks better.

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
