From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Mon, 23 Jun 2014 09:20:47 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD03BC30C@AMSPEX01CL01.citrite.net>
References: <20140622.001355.624567316306796984.davem@davemloft.net>
	<20140622111657.GA7528@zion.uk.xensource.com>
	<9AAE0902D5BC7E449B7C8E4E778ABCD03BBD51@AMSPEX01CL01.citrite.net>
 <20140623.020842.1000912698437075036.davem@davemloft.net>
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
Received: from smtp.eu.citrix.com ([185.25.65.24]:39651 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555AbaFWJUs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:20:48 -0400
In-Reply-To: <20140623.020842.1000912698437075036.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 23 June 2014 10:09
> To: Paul Durrant
> Cc: Wei Liu; xen-devel@lists.xen.org; netdev@vger.kernel.org;
> boris.ostrovsky@oracle.com; Ian Campbell
> Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our
> own module
> 
> From: Paul Durrant <Paul.Durrant@citrix.com>
> Date: Mon, 23 Jun 2014 07:59:16 +0000
> 
> > Bear in mind that the original intention of the multi-queue patches
> > was to allow the queue selection algorithm to be negotiated with the
> > frontend (see
> > http://lists.xen.org/archives/html/xen-devel/2013-06/msg02654.html).
> Particularly,
> > if the frontend is Windows then netback will need to use a Toeplitz
> > hash to steer traffic since this is stipulated by Microsoft's RSS
> > (Receive Side Scaling) interfaces. So, IMO netback should always
> > implement a select queue method, otherwise any (theoretical)
> > algorithm change in __netdev_pick_tx() would be immediately imposed
> > on frontends, possibly causing them to misbehave.
> 
> I do not think you are obligated to use Toeplitz or whatever scheme
> the other side wants, especially if the user on the xen-netback side
> asked for XPS or similar to be used.

If the frontend can only cope with one steering algorithm then how's that going to work? Flows would come in on the 'wrong' queue as far as the frontend is concerned and then who knows what would happen? If the frontend says it can only handle 'algorithm X' then the backend should either guarantee it's going to use 'algorthm X' or it should use a single queue.

  Paul
