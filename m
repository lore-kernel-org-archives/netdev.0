From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ixgbe: correctly handling failed allocation
Date: Tue, 29 Dec 2015 15:51:50 -0800
Message-ID: <CAKgT0UcxqU9HBMDLKAq4-pJdAQveoGs8sQJHWoFegF3qY+RYEg@mail.gmail.com>
References: <1451426117-30986-1-git-send-email-wuninsu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu
To: Insu Yun <wuninsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33491 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbbL2Xvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2015 18:51:50 -0500
In-Reply-To: <1451426117-30986-1-git-send-email-wuninsu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2015 at 1:55 PM, Insu Yun <wuninsu@gmail.com> wrote:
> Since kzalloc can be failed in memory pressure,
> NULL derefence could be happened.
>
> Signed-off-by: Insu Yun <wuninsu@gmail.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index aed8d02..aa5eda0 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -5331,6 +5331,8 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
>         adapter->mac_table = kzalloc(sizeof(struct ixgbe_mac_addr) *
>                                      hw->mac.num_rar_entries,
>                                      GFP_ATOMIC);
> +       if (!adapter->mac_table)
> +               return -ENOMEM;
>
>         /* Set MAC specific capability flags and exceptions */
>         switch (hw->mac.type) {
> --
> 1.9.1

That change is already present in the current net-next.

Take a look at commit 530fd82a9fea ("ixgbe: Return error on failure to
allocate mac_table").

- Alex
