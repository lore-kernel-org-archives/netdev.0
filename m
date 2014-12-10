From: Karen Xie <kxie@chelsio.com>
Subject: RE: [PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr
Date: Wed, 10 Dec 2014 16:27:22 +0000
Message-ID: <1442C3287A121140B690F7F20F94463D82EC63@nice.asicdesigners.com>
References: <201412100143.sBA1hSF4024918@localhost6.localdomain6>
 <54885415.4020105@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hariprasad S <hariprasad@chelsio.com>,
	Anish Bhatt <anish@chelsio.com>,
	"hch@infradead.org" <hch@infradead.org>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"michaelc@cs.wisc.edu" <michaelc@cs.wisc.edu>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12354 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756091AbaLJQ3I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 11:29:08 -0500
In-Reply-To: <54885415.4020105@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review. V6 has been submitted to address this.

-----Original Message-----
From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
Sent: Wednesday, December 10, 2014 6:09 AM
To: Karen Xie; linux-scsi@vger.kernel.org; netdev@vger.kernel.org
Cc: Hariprasad S; Anish Bhatt; hch@infradead.org; James.Bottomley@HansenPartnership.com; michaelc@cs.wisc.edu; davem@davemloft.net
Subject: Re: [PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr

Hello.

On 12/10/2014 4:43 AM, Karen Xie wrote:

> [PATCH net v5 2/7] cxgb4i: fix credit check for tx_data_wr

> From: Karen Xie <kxie@chelsio.com>

> make sure any tx credit related checking is done before adding the wr header.

> Signed-off-by: Karen Xie <kxie@chelsio.com>
> ---
>   drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    9 +++++----
>   1 files changed, 5 insertions(+), 4 deletions(-)

> diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c 
> b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> index f119a67..56dbd25 100644
> --- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> +++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
> @@ -547,15 +547,16 @@ static inline void make_tx_data_wr(struct 
> cxgbi_sock *csk, struct sk_buff *skb,
[...]
>   		req->op_to_immdlen = htonl(FW_WR_OP(FW_OFLD_TX_DATA_WR) |
> -					FW_WR_COMPL(1) |
> -					FW_WR_IMMDLEN(dlen));
> +					   FW_WR_COMPL(1) |
> +					   FW_WR_IMMDLEN(dlen));
>   		req->flowid_len16 = htonl(FW_WR_FLOWID(csk->tid) |
> -						FW_WR_LEN16(credits));
> +					  FW_WR_LEN16(credits));

    The above looks like unrelated cleanup, worth putting in a separate net-next patch...

WBR, Sergei
