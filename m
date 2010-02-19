From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: Re: [PATCH v3 1/2] e1000e: Only disable ASPM on
 82573L	devices
Date: Fri, 19 Feb 2010 13:53:01 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9061394282@orsmsx509.amr.corp.intel.com>
References: <1265912094-4705-1-git-send-email-mjg@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Matthew Garrett <mjg@redhat.com>, "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1265912094-4705-1-git-send-email-mjg@redhat.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thursday, February 11, 2010 10:15 AM, Matthew Garrett wrote:
> The 82537 errata and comment in e1000e_disable_l1aspm both agree that
> only 82537L devices are affected. Limit the L1 disable to them.
> 
> Signed-off-by: Matthew Garrett <mjg@redhat.com>
> ---
>  drivers/net/e1000e/netdev.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 57f149b..27eed81 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -4642,6 +4642,10 @@ static void e1000e_disable_l1aspm(struct
> pci_dev *pdev) 
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

Hi Matthew,

Exactly which erratum are you referring to?  Erratum 17 in the 82573 Specification Update?  If that is the case, I see the possibility of another interpretation of the erratum which suggests the possibility of the same issue on other variants of the 82573 when using standard frame sizes and ASPM enabled.  Not to mention, I believe there may be other parts (82574 perhaps) that will have issues with L1 ASPM enabled.  I will follow-up with the folks who did the investigation that resulted in the erratum in order to get a clearer picture of all this, and take a look into other parts that may likewise be affected.

Thanks,
Bruce.
------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
