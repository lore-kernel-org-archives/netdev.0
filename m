From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH V2 2/2] xen-netfront: limit vnic max_queues number
 to online cpus
Date: Fri, 23 Oct 2015 03:30:54 -0600
Message-ID: <562A1A6E02000078000ADEFB@prv-mh.provo.novell.com>
References: <5629FB31.5060806@oracle.com> <5629FB86.7010107@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	<xen-devel@lists.xenproject.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "Joe Jin" <joe.jin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:55836 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbJWJaz convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Fri, 23 Oct 2015 05:30:55 -0400
In-Reply-To: <5629FB86.7010107@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 23.10.15 at 11:19, <joe.jin@oracle.com> wrote:
>  
> @@ -164,6 +166,19 @@ struct netfront_rx_info {
>  	struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
>  };
>  
> +static int xennet_set_max_queues(const char *val, struct kernel_param *kp)
> +{
> +	unsigned int cpus = num_online_cpus();
> +	unsigned int max_queues = simple_strtoul(val, NULL, 10);
> +
> +	if (max_queues == 0 || max_queues > cpus) {
> +		pr_err("max_queues %u is out of range [0 - %u]!\n", 

I suppose you mean "...[1 - %u]!\n" here?

Jan
