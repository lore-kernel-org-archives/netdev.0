From: Borislav Petkov <bp@suse.de>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Tue, 29 Nov 2016 10:01:41 +0100
Message-ID: <20161129090141.qabvgzjrwd4wd2ql@pd.tnic>
References: <20161129112232.333d3363@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Tom Lendacky <thomas.lendacky@amd.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161129112232.333d3363@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 29, 2016 at 11:22:32AM +1100, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in:
> 
>   drivers/net/ethernet/amd/xgbe/xgbe-main.c
> 
> between commit:
> 
>   91eefaabf102 ("amd-xgbe: Fix unused suspend handlers build warning")
> 
> from the net tree and commit:
> 
>   bd8255d8ba35 ("amd-xgbe: Prepare for supporting PCI devices")
> 
> from the net-next tree.
> 
> I fixed it up (the latter removed the code modified by the former)

... except that +#ifdef CONFIG_PM is present in the new
drivers/net/ethernet/amd/xgbe/xgbe-platform.c now.

So actually the proper fix is, IMO, to convert:

+#ifdef CONFIG_PM
+static int xgbe_platform_suspend(struct device *dev)

to

+#ifdef CONFIG_PM_SLEEP
+static int xgbe_platform_suspend(struct device *dev)

so that it doesn't fire again.

David, would you prefer a patch against linux-next?

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix Imendörffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nürnberg)
-- 
