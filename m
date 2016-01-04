From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH] rt2x00pci: Disable memory-write-invalidate when the
 driver exits
Date: Mon, 4 Jan 2016 17:50:36 +0100
Message-ID: <CAGXE3d9tTr6hyOjh==Mn5tNQSy-hMBhxtmsWNY_tLgJqE=B38A@mail.gmail.com>
References: <1451894138-3482-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, kvalo@codeaurora.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451894138-3482-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 4, 2016 at 8:55 AM, Jia-Ju Bai <baijiaju1990@163.com> wrote:
> The driver calls pci_set_mwi to enable memory-write-invalidate when it
> is initialized, but does not call pci_clear_mwi when it is removed. Many
> other drivers calls pci_clear_mwi when pci_set_mwi is called, such as
> r8169, 8139cp and e1000.
>
> This patch adds pci_clear_mwi in error handling and removal procedure,
> which can fix the problem.
>
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Looks good to me.
Does this fix any actual issue?
If yes it might we worth to mention it in the commit message.
Helmut


> ---
>  drivers/net/wireless/rt2x00/rt2x00pci.c |    2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
> index d93db4b..eb6dbcd 100644
> --- a/drivers/net/wireless/rt2x00/rt2x00pci.c
> +++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
> @@ -149,6 +149,7 @@ exit_free_device:
>         ieee80211_free_hw(hw);
>
>  exit_release_regions:
> +       pci_clear_mwi(pci_dev);
>         pci_release_regions(pci_dev);
>
>  exit_disable_device:
> @@ -173,6 +174,7 @@ void rt2x00pci_remove(struct pci_dev *pci_dev)
>         /*
>          * Free the PCI device data.
>          */
> +       pci_clear_mwi(pci_dev);
>         pci_disable_device(pci_dev);
>         pci_release_regions(pci_dev);
>  }
> --
> 1.7.9.5
>
>
