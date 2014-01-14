From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC v2 0/13] vti4: prepare namespace and interfamily
 support.
Date: Tue, 14 Jan 2014 08:51:38 +0100
Message-ID: <20140114075138.GG31491@secunet.com>
References: <20131216091835.GQ31491@secunet.com>
 <52CC2714.5080600@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Saurabh Mohan <saurabh.mohan@vyatta.com>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33243 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751172AbaANHvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 02:51:41 -0500
Content-Disposition: inline
In-Reply-To: <52CC2714.5080600@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 05:11:00PM +0100, Christophe Gouault wrote:
> 
> Sorry for my late comments, I had to delay my tests due to Christmas and
> New Year's celebrations.

Sorry for the delay on my side, I had to setup a testcase
for vti with namespaces first.

> 
> I have a few comments about your proposed patches:
> 
> In input, the vti tunnel processing does not follow the usual tunnel
> processing. Conventionally, the packets are first decapsulated, then
> only the skbuff interface is changed to the tunnel interface. In the vti
> code, the interface is changed before IPsec decryption, hence before
> decapsulation.
> 
> It results in a configuration asymmetry when we later support cross
> netns: the outer SAs and SPs must be defined in the outer netns, while
> the inner SAs and SPs must be defined in the inner netns.

You are absolutely right here. I'll change this to do the namespace
transition after the decapsulation in the vti_rcv_cb() callback.
Then in and outbound states/policies must be defined in the outer
namespace. I'll send another RFC version of that patchset during the
next days.

Thanks for pointing this out!
