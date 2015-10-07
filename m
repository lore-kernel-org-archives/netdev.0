From: Maurizio Lombardi <mlombard@redhat.com>
Subject: Re: [PATCH] bnx2fc: reduce stack usage in __bnx2fc_enable
Date: Wed, 7 Oct 2015 15:28:35 +0200
Message-ID: <56151E03.4050908@redhat.com>
References: <5002023.QHmpbQ8s70@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: QLogic-Storage-Upstream@qlogic.com,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joe Carnuccio <joe.carnuccio@qlogic.com>,
	Chad Dupuis <chad.dupuis@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <5002023.QHmpbQ8s70@wuerfel>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 10/07/2015 03:11 PM, Arnd Bergmann wrote:
> -	memset(&npiv_tbl, 0, sizeof(npiv_tbl));
> -	if (hba->cnic->get_fc_npiv_tbl(hba->cnic, &npiv_tbl))
> +	npiv_tbl = kzalloc(sizeof(struct cnic_fc_npiv_tbl), GFP_KERNEL);
> +	if (!npiv_tbl)
>  		goto done;
>  

If kzalloc() fails perhaps the function should return -ENOMEM, not zero.


Regards,
Maurizio Lombardi
