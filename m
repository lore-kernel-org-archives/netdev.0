From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 5/7] xen-netfront: reduce gso_max_size to account for
 ethernet header
Date: Fri, 12 Apr 2013 09:57:15 +0100
Message-ID: <1365757035.15783.4.camel@zakaz.uk.xensource.com>
References: <1365505655-8021-1-git-send-email-wei.liu2@citrix.com>
	 <1365505655-8021-6-git-send-email-wei.liu2@citrix.com>
	 <20130411200401.GJ5936@zion.uk.xensource.com>
	 <1365754684.8126.82.camel@zakaz.uk.xensource.com>
	 <20130412084822.GA11321@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:40165 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448Ab3DLI5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 04:57:18 -0400
In-Reply-To: <20130412084822.GA11321@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 09:48 +0100, Wei Liu wrote:
> On Fri, Apr 12, 2013 at 09:18:04AM +0100, Ian Campbell wrote:
> > On Thu, 2013-04-11 at 21:04 +0100, Wei Liu wrote:
> > > On Tue, Apr 09, 2013 at 12:07:33PM +0100, Wei Liu wrote:
> > > > The maximum packet including ethernet header that can be handled by netfront /
> > > > netback wire format is 65535. Reduce gso_max_size accordingly.
> > > > 
> > > > Drop skb and print warning when skb->len > 65535. This can 1) save the effort
> > > > to send malformed packet to netback, 2) help spotting misconfiguration of
> > > > netfront in the future.
> > > > 
> > > 
> > > Any opinion on how much space should be reserved? From a previous thread
> > > Ben seemed to suggest 90 (Ethernet + VLAN tag + IPv6 + TCP + timestamp
> > > option = 90 bytes).
> > 
> > I trust Ben and that seems as good as anything to me.
> > 
> > Is this the sort of limit others might be interested in, should we have
> > a global #define?
> > 
> 
> We shall have a global define in this case.
> 
> #define XEN_NETFRONT_MAX_HEADER ? I'm bad at naming things.

I meant an include/linux/skbuff.h (or some suitable header) #define
SKB_MAX_FOO type thing...

Ian.
