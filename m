From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [RFC PATCH 1/7] PF driver modified to enable HW filter support,
 changes works in backward compatibility mode Enable required things in
 Makefile Enable LZ4 dependecy inside config file
Date: Wed, 21 Dec 2016 18:35:20 +0530
Message-ID: <CA+sq2CfwTN5u6nhxriqWqoFxsYHdEYikbjBgMCL2YwNXpqyQ=Q@mail.gmail.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com> <1482310011-1862-2-git-send-email-satha.rao@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        David Daney <david.daney@cavium.com>,
        rvatsavayi@caviumnetworks.com, derek.chickles@caviumnetworks.com,
        philip.romanov@cavium.com,
        Linux Netdev List <netdev@vger.kernel.org>,
        LAKML <linux-arm-kernel@lists.infradead.org>
To: Satha Koteswara Rao <satha.rao@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482310011-1862-2-git-send-email-satha.rao@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
>  #define NIC_MAX_RSS_HASH_BITS          8
>  #define NIC_MAX_RSS_IDR_TBL_SIZE       (1 << NIC_MAX_RSS_HASH_BITS)
> +#define NIC_TNS_RSS_IDR_TBL_SIZE       5

So you want to use only 5 queues per VF when TNS is enabled, is it ??
There are 4096 RSS indices in total, for each VF you can use max 32.
I guess you wanted to set no of hash bits to 5 instead of table size.

>  #define RSS_HASH_KEY_SIZE              5 /* 320 bit key */
>
>  struct nicvf_rss_info {
> @@ -255,74 +258,6 @@ struct nicvf_drv_stats {
>         struct u64_stats_sync   syncp;
>  };
>
> -struct nicvf {
> -       struct nicvf            *pnicvf;
> -       struct net_device       *netdev;
> -       struct pci_dev          *pdev;
> -       void __iomem            *reg_base;

Didn't get why you moved this structure to the end of file.
Looks like an unnecessary modification.


> +static unsigned int num_vfs;
> +module_param(num_vfs, uint, 0644);
> +MODULE_PARM_DESC(num_vfs, "Non zero positive value, specifies number of VF's per physical port");

So what if driver is built-in instead of module, I can't use TNS is it ?

>
> +/* Set RBDR Backpressure (RBDR_BP) and CQ backpressure (CQ_BP) of vnic queues
> + * to 129 each

Why 129 ??
RBDR minimum size is 8K buffers, why you want to assert BP when still
~4K buffers
are available. Isn't 4K a huge number to start asserting backpressure ?
