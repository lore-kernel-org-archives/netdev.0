From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 22/26] ixgb: Cache-align all TX components of the adapter struct.
Date: Tue, 29 Aug 2006 19:33:55 +0200
Message-ID: <200608291933.56002.dada1@cosmosbay.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164503.6872.93015.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	akpm@osdl.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40587 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S965173AbWH2Rdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 13:33:52 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060829164503.6872.93015.stgit@gitlost.site>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 29 August 2006 18:45, Kok, Auke wrote:
>
>  	/* TX */
> -	struct ixgb_desc_ring tx_ring;
> +	struct ixgb_desc_ring tx_ring ____cacheline_aligned;
>  	unsigned long timeo_start;

On UP, this would only enlarge the size of structure and might consume more 
cache lines...

 I guess ____cacheline_aligned_in_smp is preferred here.

(see include/linux/netdevice.h)

Eric

