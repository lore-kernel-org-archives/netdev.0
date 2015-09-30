From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/3] RDS-TCP: Set up MSG_MORE and
 MSG_SENDPAGE_NOTLAST as appropriate in rds_tcp_xmit
Date: Wed, 30 Sep 2015 17:53:20 +0300
Message-ID: <560BF760.9000901@cogentembedded.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
 <4471e1253cbbd917c1b1bd62b5b14844c19a857f.1443569239.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com,
	santosh.shilimkar@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4471e1253cbbd917c1b1bd62b5b14844c19a857f.1443569239.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09/30/2015 04:45 PM, Sowmini Varadhan wrote:

> For the same reasons as 2f53384424 and 35f9c09fe9, rds_tcp_xmit
> may have multiple pages to send, so use the MSG_MORE and
> MSG_SENDPAGE_NOTLAST as hints to tcp_sendpage()
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>   net/rds/tcp_send.c |    8 +++++++-
>   1 files changed, 7 insertions(+), 1 deletions(-)
>
> diff --git a/net/rds/tcp_send.c b/net/rds/tcp_send.c
> index 53b17ca..5f3e3fa 100644
> --- a/net/rds/tcp_send.c
> +++ b/net/rds/tcp_send.c
[...]
> @@ -116,12 +117,15 @@ int rds_tcp_xmit(struct rds_connection *conn, struct rds_message *rm,
>   			goto out;
>   	}
>
> +	more = (rm->data.op_nents > 1 ? (MSG_MORE | MSG_SENDPAGE_NOTLAST) : 0);

    No need for either inner or outer parens.

>   	while (sg < rm->data.op_nents) {
> +		int flags = (MSG_DONTWAIT | MSG_NOSIGNAL | more);

    Parens not needed as well.

[...]

MBR, Sergei
