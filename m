From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 net-next 5/8] sunvnet: straighten up message event
 handling logic
Date: Mon, 13 Feb 2017 11:06:42 -0800
Message-ID: <1487012802.6214.3.camel@perches.com>
References: <1487012224-403399-1-git-send-email-shannon.nelson@oracle.com>
         <1487012224-403399-6-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487012224-403399-6-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-02-13 at 10:57 -0800, Shannon Nelson wrote:
> The use of gotos for handling the incoming events made this code
> harder to read and support than it should be.  This patch straightens
> out and clears up the logic.
> 
> Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
> ---
>  drivers/net/ethernet/sun/sunvnet_common.c |   94 ++++++++++++++---------------
>  1 files changed, 45 insertions(+), 49 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
[]
> @@ -738,41 +738,37 @@ static int vnet_event_napi(struct vnet_port *port, int budget)
[]
> +	/* we don't expect any other bits */
> +	BUG_ON(port->rx_event & ~(LDC_EVENT_DATA_READY |
> +				  LDC_EVENT_RESET |
> +				  LDC_EVENT_UP));

Is it really necessary to use BUG_ON here?
