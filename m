From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 17/20] net/xen-netfront: Make it running
 on 64KB page granularity
Date: Mon, 20 Jul 2015 18:26:06 +0100
Message-ID: <55AD2F2E.9090204@citrix.com>
References: <1436474552-31789-1-git-send-email-julien.grall@citrix.com>
 <1436474552-31789-18-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436474552-31789-18-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/07/15 21:42, Julien Grall wrote:
> +static void xennet_make_one_txreq(unsigned long mfn, unsigned int offset,
> +				  unsigned int *len, void *data)
> +{
> +	struct xennet_gnttab_make_txreq *info = data;
> +
> +	info->tx->flags |= XEN_NETTXF_more_data;
> +	skb_get(info->skb);
> +	xennet_make_one_txreq(mfn, offset, len, data);

This should be xennet_tx_setup_grant rather than calling itself. I did
the mistake while cleaning up the code sorry.

Regards,

-- 
Julien Grall
