From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V4 7/7] xen-netback: don't disconnect frontend when
 seeing oversize packet
Date: Mon, 15 Apr 2013 15:53:20 +0100
Message-ID: <20130415145320.GE17602@zion.uk.xensource.com>
References: <1365776646-10796-1-git-send-email-wei.liu2@citrix.com>
 <1365776646-10796-8-git-send-email-wei.liu2@citrix.com>
 <CAJ75kXb1Pc83sAjqDuzeGiikTcqdqrgPTxTT7kS-agUqoZp7LA@mail.gmail.com>
 <1366016605.4963.6.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: William Dauchy <wdauchy@gmail.com>, Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"jbeulich@suse.com" <jbeulich@suse.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61263 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983Ab3DOOxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 10:53:22 -0400
Content-Disposition: inline
In-Reply-To: <1366016605.4963.6.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 10:03:25AM +0100, Ian Campbell wrote:
> On Fri, 2013-04-12 at 18:17 +0100, William Dauchy wrote:
> > On Fri, Apr 12, 2013 at 4:24 PM, Wei Liu <wei.liu2@citrix.com> wrote:
> > > Some frontend drivers are sending packets > 64 KiB in length. This length
> > > overflows the length field in the first slot making the following slots have
> > > an invalid length.
> > >
> > > Turn this error back into a non-fatal error by dropping the packet. To avoid
> > > having the following slots having fatal errors, consume all slots in the
> > > packet.
> > >
> > > This does not reopen the security hole in XSA-39 as if the packet as an
> > > invalid number of slots it will still hit fatal error case.
> > >
> > > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> > > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > 
> > Maybe this should be tagged for stable? Maybe part of patch 6/7 as
> > well. I had to remove the part which was disabling the device because
> > of issues encountered in stable tree.
> 
> AFAICT the majority of this series (as well as perhaps some of Wei's
> earlier fixes) should be candidates for any stable tree which received
> the XSA-39 security fixes. Wei -- could you enumerate which patches are
> required to fixup the XSA-39 regressions?
> 

Are mechinical fixes such as removing redudent variables / changing log
messages candidates for stable? 1-4 are such kind of fixes.

5-7 are the real meat. If 1-4 are not taken to stable, they will need
small adjustment to apply, which is just trivial.


Wei.

> Ian.
> 
