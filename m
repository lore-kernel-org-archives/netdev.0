From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 10:48:13 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD01ABD2E@AMSPEX01CL01.citrite.net>
References: <1386670600-5882-1-git-send-email-paul.durrant@citrix.com>
 <1386671136.11925.46.camel@kazak.uk.xensource.com>
 <52A6ED35.7070003@citrix.com> <20131210103736.GJ32155@zion.uk.xensource.com>
 <20131210104443.GK32155@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16333 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751687Ab3LJKsQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 05:48:16 -0500
In-Reply-To: <20131210104443.GK32155@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 10 December 2013 10:45
> To: David Vrabel
> Cc: Ian Campbell; Paul Durrant; xen-devel@lists.xen.org;
> netdev@vger.kernel.org; Wei Liu
> Subject: Re: [PATCH net] xen-netback: fix abuse of napi budget
> 
> On Tue, Dec 10, 2013 at 10:37:36AM +0000, Wei Liu wrote:
> > On Tue, Dec 10, 2013 at 10:30:13AM +0000, David Vrabel wrote:
> > > On 10/12/13 10:25, Ian Campbell wrote:
> > > > On Tue, 2013-12-10 at 10:16 +0000, Paul Durrant wrote:
> > > >> netback seemed to be somewhat confused about the napi budget
> parameter and
> > > >> basically ignored it. This patch fixes that, properly limiting the work
> done
> > > >> in each poll.
> > > >
> > > > What do you mean "ignored", xenvif_tx_submit seems to be tracking
> and
> > > > testing work_done against the budget.
> > >
> > > I have seen this warning in net_rx_action() trigger.
> > >
> > > 	WARN_ON_ONCE(work > weight);
> > >
> > > Which means netback wasn't limiting the work done.
> > >
> >
> > But in the original code work_done is returned by xenvif_tx_submit which
> > has guard against that situation, right?
> >
> 
> And now I think I spot a bug...
> 
>   work_done = xenvif_tx_submit(vif, nr_gops);
> 
> The second argument should really be "budget". :-(
> 

Yep - that's basically the problem.

  Paul

> Wei.
> 
> > Wei.
> >
> > > David
