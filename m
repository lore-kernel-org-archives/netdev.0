From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2] ehea: Receive SKB Aggregation
Date: Thu, 31 May 2007 09:37:03 -0700
Message-ID: <20070531093703.373995b2@freepuppy>
References: <200705311354.56979.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:45192 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760599AbXEaQsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 12:48:40 -0400
In-Reply-To: <200705311354.56979.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
>  
> +static int try_get_ip_tcp_hdr(struct ehea_cqe *cqe, struct sk_buff *skb,
> +			      struct iphdr **iph, struct tcphdr **tcph)
> +{
> +	int ip_len;
> +
> +	/* non tcp/udp packets */
> +	if (!cqe->header_length)
> +		return -1;
> +
> +	/* non tcp packet */
> +	*iph = (struct iphdr *)(skb->data);

Why the indirection, copying of headers..

> +	if ((*iph)->protocol != IPPROTO_TCP)
> +		return -1;
> +
> +	ip_len = (u8)((*iph)->ihl);
> +	ip_len <<= 2;
> +	*tcph = (struct tcphdr *)(((u64)*iph) + ip_len);
> +
> +	return 0;
> +}
> +
> 

This code seems to be duplicating a lot  (but not all) of the TCP/IP
input path validation checks. This is a security problem if nothing else...

Also, how do you prevent DoS attacks from hostile TCP senders that send
huge number of back to back frames?

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
