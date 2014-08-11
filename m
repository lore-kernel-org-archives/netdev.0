From: James Smart <james.smart@emulex.com>
Subject: Re: [PATCH net-next 2/2] random32: do not feed jiffies as seed from
 lpfc driver
Date: Mon, 11 Aug 2014 13:07:15 -0400
Message-ID: <282a2dc3-6381-42d6-ac34-81ceb56f1534@CMEXHTCAS2.ad.emulex.com>
References: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Reply-To: <james.smart@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	James Bottomley <JBottomley@Parallels.com>,
	"Smart, James" <James.Smart@Emulex.Com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by:  James Smart  <james.smart@emulex.com>

-- james  s



On 7/31/2014 4:08 PM, Daniel Borkmann wrote:
> In prandom we have already reseeding mechanisms that trigger
> periodically from a much better entropy source than just
> feeding in jiffies through lpfc_mbx_cmpl_fcf_scan_read_fcf_rec()
> [what a function name 8-)]. Therefore, just remove this.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: James Bottomley <JBottomley@Parallels.com>
> Cc: James Smart <james.smart@emulex.com>
> ---
>   This can also go via James, how you prefer it.
>
>   drivers/scsi/lpfc/lpfc_hbadisc.c | 4 ----
>   1 file changed, 4 deletions(-)
>
> diff --git a/drivers/scsi/lpfc/lpfc_hbadisc.c b/drivers/scsi/lpfc/lpfc_hbadisc.c
> index 2a17e31..5072bb2 100644
> --- a/drivers/scsi/lpfc/lpfc_hbadisc.c
> +++ b/drivers/scsi/lpfc/lpfc_hbadisc.c
> @@ -2146,7 +2146,6 @@ lpfc_mbx_cmpl_fcf_scan_read_fcf_rec(struct lpfc_hba *phba, LPFC_MBOXQ_t *mboxq)
>   	uint16_t fcf_index, next_fcf_index;
>   	struct lpfc_fcf_rec *fcf_rec = NULL;
>   	uint16_t vlan_id;
> -	uint32_t seed;
>   	bool select_new_fcf;
>   	int rc;
>   
> @@ -2383,9 +2382,6 @@ lpfc_mbx_cmpl_fcf_scan_read_fcf_rec(struct lpfc_hba *phba, LPFC_MBOXQ_t *mboxq)
>   		phba->fcf.fcf_flag |= FCF_AVAILABLE;
>   		/* Setup initial running random FCF selection count */
>   		phba->fcf.eligible_fcf_cnt = 1;
> -		/* Seeding the random number generator for random selection */
> -		seed = (uint32_t)(0xFFFFFFFF & jiffies);
> -		prandom_seed(seed);
>   	}
>   	spin_unlock_irq(&phba->hbalock);
>   	goto read_next_fcf;

