From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH 1/4] xen-netfront: remove unused variable
 `extra'
Date: Tue, 19 Mar 2013 10:03:58 +0000
Message-ID: <291EDFCB1E9E224A99088639C4762022013F7D2D3563@LONPMAILBOX01.citrite.net>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
 <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>
 <1363606922.30193.21.camel@zakaz.uk.xensource.com>
 <1363608271.29093.196.camel@zion.uk.xensource.com>
 <1363608860.30193.39.camel@zakaz.uk.xensource.com>
 <5147CFD2.8040803@oracle.com>
 <291EDFCB1E9E224A99088639C4762022013F7D2D3543@LONPMAILBOX01.citrite.net>
 <5148359C.8040906@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:45165 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604Ab3CSKD6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 06:03:58 -0400
In-Reply-To: <5148359C.8040906@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
[snip] 
> For TCPv4 GSO, it seems one extra info request(NETTXF_extra_info) is
> enough in my winpv driver, and I did not process the
> XEN_NETIF_EXTRA_MORE.
> Do you create two extra info requests for bothTCPv4 and TCPv6 GSO like
> following?
> 
>   * [Request 2: netif_tx_extra]  (only if request 1 has NETTXF_extra_info)
>   * [Request 3: netif_tx_extra]  (only if request 2 has
> XEN_NETIF_EXTRA_MORE)
> 

No, I just use one. I don't use XEN_NETIF_EXTRA_FLAG_MORE. I thought you were questioning the existence of extra segments rather than this flag. I guess I got the wrong end of the stick.
I've not seen anything use XEN_NETIF_EXTRA_FLAG_MORE, but that's not to say nothing will use it in the future. Clearly something is needed to indicate subsequent extra segments should they ever be needed.

  Paul

> 
> > Extra segments are certainly not redundant; the Citrix Windows PV drivers
> send TSOs using them and handle LRO using them too.
> 
> About the LRO, upstream netback does not create any response with
> XEN_NETIF_EXTRA_MORE, so I assume your dom0 did such process?
> 
> Thanks
> Annie
