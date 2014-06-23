From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Mon, 23 Jun 2014 09:30:52 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD03BC3A1@AMSPEX01CL01.citrite.net>
References: <9AAE0902D5BC7E449B7C8E4E778ABCD03BBD51@AMSPEX01CL01.citrite.net>
	<20140623084831.GV20819@zion.uk.xensource.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD03BC2F7@AMSPEX01CL01.citrite.net>
 <20140623.022532.105159906302303437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:32468 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaFWJax convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:30:53 -0400
In-Reply-To: <20140623.022532.105159906302303437.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 23 June 2014 10:26
> To: Paul Durrant
> Cc: Wei Liu; xen-devel@lists.xen.org; netdev@vger.kernel.org;
> boris.ostrovsky@oracle.com; Ian Campbell
> Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our
> own module
> 
> From: Paul Durrant <Paul.Durrant@citrix.com>
> Date: Mon, 23 Jun 2014 09:18:23 +0000
> 
> > Ok, for the addition of a new algorithm that may be the case but
> > what about the existent algorithm stability issue? Who's going to
> > watch the implementation of __netdev_pick_tx() and make sure there
> > is no semantic change? I'm still of the opinion that the
> > implementation should be kept within netback so that we can
> > guarantee stability, even if it means duplication. Either that or we
> > need some guarantee that the semantic of __netdev_pick_tx() will
> > never change.
> 
> Please stop talking like this.
> 
> If the default changes it's probably to fix a bug or make things
> better, you want no bugs to get fix if it breaks "stability"?

To some extent, yes. My hypothesis is that the frontend and the backend agree a steering algorithm so that they can ensure all rx and tx traffic for a flow hits a particular CPU, so that locking can be avoided. If the backend then changes its algorithm then packets may arrive on the wrong queue, hit the wrong CPU and now you have a frontend that may try to access critical data structures without locking from two different CPUs. That's going to be a pretty subtle crash to have to debug.

  Paul
