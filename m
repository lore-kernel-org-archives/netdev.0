From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: ixgbevf: bug in error handling
Date: Thu, 11 Mar 2010 08:58:02 -0800
Message-ID: <43F901BD926A4E43B106BF17856F0755A34AAC48@orsmsx508.amr.corp.intel.com>
References: <20100311103329.GO6321@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65401 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933307Ab0CKQ6E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 11:58:04 -0500
In-Reply-To: <20100311103329.GO6321@bicker>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Dan Carpenter [mailto:error27@gmail.com]
>Sent: Thursday, March 11, 2010 2:33 AM
>To: Rose, Gregory V
>Cc: netdev@vger.kernel.org; kernel-janitors@vger.kernel.org
>Subject: ixgbevf: bug in error handling
>
>Hi Greg,
>
>drivers/net/ixgbevf/ixgbevf_main.c +3013 ixgbevf_tx_map(96) warn:
>unsigned 'i' is never less than zero.
>  3010          while (count >= 0) {
>  3011                  count--;
>  3012                  i--;
>  3013                  if (i < 0)
>  3014                          i += tx_ring->count;
>
>	There is a problem here because i is unsigned and just wraps
>	around instead of being less than 0.
>
>  3015                  tx_buffer_info = &tx_ring->tx_buffer_info[i];
>  3016                  ixgbevf_unmap_and_free_tx_resource(adapter,
>tx_buffer_info);
>  3017          }
>
>regards,
>dan carpenter

Ouch.  Good catch, we'll fix that right away.

- Greg

