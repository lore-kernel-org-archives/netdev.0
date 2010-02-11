From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH v2 1/2] e1000e: Only disable ASPM on
	82573L devices
Date: Thu, 11 Feb 2010 09:17:12 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1002110916130.6892@jbrandeb-desk1.amr.corp.intel.com>
References: <1265905767-3884-1-git-send-email-mjg@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matthew Garrett <mjg@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1265905767-3884-1-git-send-email-mjg@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On Thu, 11 Feb 2010, Matthew Garrett wrote:

> The 82537 errata and comment in e1000e_disable_l1aspm both agree that
> only 82537L devices are affected. Limit the L1 disable to them.

Hi Matthew, its a nitpick, but can you please change the part number to 
the correct one?  it should be s/82537/82573

 
> Signed-off-by: Matthew Garrett <mjg@redhat.com>
> ---
>  drivers/net/e1000e/netdev.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 57f149b..27eed81 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -4642,6 +4642,10 @@ static void e1000e_disable_l1aspm(struct pci_dev *pdev)
>  	 * Unfortunately this feature saves about 1W power consumption when
>  	 * active.
>  	 */
> +
> +	if (pdev->device != E1000_DEV_ID_82573L)
> +		return;
> +
>  	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
>  	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
>  	if (val & 0x2) {
> 

------------------------------------------------------------------------------
SOLARIS 10 is the OS for Data Centers - provides features such as DTrace,
Predictive Self Healing and Award Winning ZFS. Get Solaris 10 NOW
http://p.sf.net/sfu/solaris-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
