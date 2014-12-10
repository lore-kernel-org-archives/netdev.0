From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr
Date: Wed, 10 Dec 2014 17:09:25 +0300
Message-ID: <54885415.4020105@cogentembedded.com>
References: <201412100143.sBA1hSF4024918@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, anish@chelsio.com, hch@infradead.org,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
To: Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201412100143.sBA1hSF4024918@localhost6.localdomain6>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/10/2014 4:43 AM, Karen Xie wrote:

> [PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr

> From: Karen Xie <kxie@chelsio.com>

> make sure any tx credit related checking is done before adding the wr header.

> Signed-off-by: Karen Xie <kxie@chelsio.com>
> ---
>   drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    9 +++++----
>   1 files changed, 5 insertions(+), 4 deletions(-)

> diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> index f119a67..56dbd25 100644
> --- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> +++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> @@ -547,15 +547,16 @@ static inline void make_tx_data_wr(struct cxgbi_sock *csk, struct sk_buff *skb,
[...]
>   		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
> -					FW_WR_COMPL(1) |
> -					FW_WR_IMMDLEN(dlen));
> +					   FW_WR_COMPL(1) |
> +					   FW_WR_IMMDLEN(dlen));
>   		req->flowid_len16 = htonl(FW_WR_FLOWID(csk->tid) |
> -						FW_WR_LEN16(credits));
> +					  FW_WR_LEN16(credits));

    The above looks like unrelated cleanup, worth putting in a separate 
net-next patch...

WBR, Sergei

