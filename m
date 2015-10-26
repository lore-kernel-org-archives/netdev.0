From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net] RDS-TCP: Recover correctly from
 pskb_pull()/pksb_trim() failure in rds_tcp_data_recv
Date: Mon, 26 Oct 2015 09:56:01 -0700
Message-ID: <562E5B21.2070509@oracle.com>
References: <20151026164637.GK10039@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151026164637.GK10039@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/26/2015 9:46 AM, Sowmini Varadhan wrote:
>
> Either of pskb_pull() or pskb_trim() may fail under low memory conditions.
> If rds_tcp_data_recv() ignores such failures, the application will
> receive corrupted data because the skb has not been correctly
> carved to the RDS datagram size.
>
> Avoid this by handling pskb_pull/pskb_trim failure in the same
> manner as the skb_clone failure: bail out of rds_tcp_data_recv(), and
> retry via the deferred call to rds_send_worker() that gets set up on
> ENOMEM from rds_tcp_read_sock()
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
Good one. Probably we should get this fix in stable versions as
well. It seems to be applicable for all v2.6.32+ stable versions.

FWIW,
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>

Regards,
Santosh
