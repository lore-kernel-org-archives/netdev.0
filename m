From: Wen Xiong <wenxiong@us.ibm.com>
Subject: Re: [PATCH] e1000: Work around 82571 completion
	timout on Pseries HW
Date: Wed, 16 May 2007 17:11:21 -0500
Message-ID: <OFF304A49A.2C1F7634-ON872572DD.0079C647-862572DD.0079EE19@us.ibm.com>
References: <464B2AB9.4050706@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0368508050=="
Cc: e1000-devel@lists.sourceforge.net,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <464B2AB9.4050706@garzik.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multipart message in MIME format.
--===============0368508050==
Content-Type: multipart/alternative;
	boundary="=_alternative 0079EE18862572DD_="

This is a multipart message in MIME format.
--=_alternative 0079EE18862572DD_=
Content-Type: text/plain; charset="US-ASCII"

Hi Jeff,

 little history, on PCI-X adapters we did not time dma reads being 
returned to the adapter. On PCIe unfortunately the spec says that adapters 
need to time the dma reads the spec is not specific on the range but the 
timers can range from worst case 50 usecs to 10 ms with some adapters 
supporting upto 50ms. The PCIe spec has approved an ECR to the PCIe 1.0a 
spec that will support the ability to disable the timer.  To work aroung 
the adapter doesn't support ECR.  We need the driver to disable the timer.

Thanks,
wendy 



Jeff Garzik <jeff@garzik.org> 
05/16/2007 11:00 AM

To
Auke Kok <auke-jan.h.kok@intel.com>
cc
Wen Xiong/Austin/IBM@IBMUS, e1000-devel@lists.sourceforge.net, 
netdev@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject
Re: [PATCH] e1000: Work around 82571 completion timout on Pseries HW






Auke Kok wrote:
> Our 82571 (first PCI-E hardware) causes P-Series hardware to throw
> issues. Disabling PCI-E completion timeouts in our NIC resolves
> the issue.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Cc: Wen Xiong <wenxiong@us.ibm.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c 
b/drivers/net/e1000/e1000_main.c
> index 49be393..830d851 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
>                                E1000_WRITE_REG(&adapter->hw, CTRL, 
ctrl);
>                }
> 
> +#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
> +#define E1000_GCR_DISABLE_TIMEOUT_MECHANISM 0x80000000
> +              if (adapter->hw.mac.type == e1000_82571) {
> +                              /* work around pSeries hardware by 
disabling timeouts */
> +                              u32 gcr = E1000_READ_REG(&adapter->hw, 
E1000_GCR);
> +                              gcr |= 
E1000_GCR_DISABLE_TIMEOUT_MECHANISM;
> +                              E1000_WRITE_REG(&adapter->hw, E1000_GCR, 
gcr);

Why is this needed?

Is pSeries PCI-E implementation problematic?  Or is this a e1000 PCI-E 
hardware bug?  If the former, I wonder if this is the best way to work 
around the issue, especially since it might crop up in other PCI-E 
boards besides e1000.  If the latter, it seems like we should disable 
the feature on all platforms.

                 Jeff




--=_alternative 0079EE18862572DD_=--


--===============0368508050==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0368508050==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--===============0368508050==--
