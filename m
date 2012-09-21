From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Subject: Re: [PATCH] rds: Error on offset mismatch if not loopback
Date: Fri, 21 Sep 2012 16:38:15 -0500
Message-ID: <505CDE47.1090300@oracle.com>
References: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: John Jolly <jjolly@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120921213239.GJ14393@linux-tkdk.sfcn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/21/2012 4:32 PM, John Jolly wrote:
> Attempting an rds connection from the IP address of an IPoIB interface
> to itself causes a kernel panic due to a BUG_ON() being triggered.
> Making the test less strict allows rds-ping to work without crashing
> the machine.
>
> A local unprivileged user could use this flaw to crash the system.
>
> Signed-off-by: John Jolly<jjolly@suse.com>
> ---
>   net/rds/ib_send.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
> index e590949..7920c85 100644
> --- a/net/rds/ib_send.c
> +++ b/net/rds/ib_send.c
> @@ -544,7 +544,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
>          int flow_controlled = 0;
>          int nr_sig = 0;
>
> -       BUG_ON(off % RDS_FRAG_SIZE);
> +       BUG_ON(!conn->c_loopback&&  off % RDS_FRAG_SIZE);
>          BUG_ON(hdr_off != 0&&  hdr_off != sizeof(struct rds_header));
>
>          /* Do not send cong updates to IB loopback */
Hi John,

How do you trigger this BUG_ON ?
With rds-ping I could not hit this condition of non-zero "off % 
RDS_FRAG_SIZE".
rds-ping uses zero byte messages to ping or pong back. How does the 
"off" become non-zero ?

Thanks.

Venkat
