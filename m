From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 5/7] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Thu, 11 Apr 2013 21:04:01 +0100
Message-ID: <20130411200401.GJ5936@zion.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
 <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	Wei Liu <wei.liu2@citrix.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26520 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751633Ab3DKUED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 16:04:03 -0400
Content-Disposition: inline
In-Reply-To: <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 12:07:33PM +0100, Wei Liu wrote:
> The maximum packet including ethernet header that can be handled by netfront /
> netback wire format is 65535. Reduce gso_max_size accordingly.
> 
> Drop skb and print warning when skb->len > 65535. This can 1) save the effort
> to send malformed packet to netback, 2) help spotting misconfiguration of
> netfront in the future.
> 

Any opinion on how much space should be reserved? From a previous thread
Ben seemed to suggest 90 (Ethernet + VLAN tag + IPv6 + TCP + timestamp
option = 90 bytes).


Wei.
