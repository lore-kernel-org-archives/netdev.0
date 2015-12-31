From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [net-next] ppp: rtnetlink device handling
Date: Thu, 31 Dec 2015 13:58:18 +0100
Message-ID: <20151231125818.GN18510@alphalink.fr>
References: <CA+icZUVb03kO3O2nqEHazotM_Df4SLUw6SOAuPXuB3eNy_gOHg@mail.gmail.com>
 <20151231104147.GM18510@alphalink.fr>
 <CA+icZUU5z_sgYTOSBGazJU9VSm6qZxfA=PXcRQ5bwj-7rOU6fQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38542 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbbLaM6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2015 07:58:21 -0500
Content-Disposition: inline
In-Reply-To: <CA+icZUU5z_sgYTOSBGazJU9VSm6qZxfA=PXcRQ5bwj-7rOU6fQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 31, 2015 at 12:01:40PM +0100, Sedat Dilek wrote:
> On Thu, Dec 31, 2015 at 11:41 AM, Guillaume Nault <g.nault@alphalink.fr> wrote:
> > On Thu, Dec 31, 2015 at 08:46:59AM +0100, Sedat Dilek wrote:
> >> Hi Guillaume,
> >>
> >> can you explain why you moved ppp to rtnetlink device handling?
> >> Benefits, etc.?
> >>
> > The objective is to bring all the flexibility of rtnetlink device
> > creation to ppp interfaces. This is particularly useful for Network
> > Access Servers which need to define device properties at creation
> > time. My use case includes setting device name and netns, which is
> > impossible with the ioctl-based interface without generating transient
> > effects.
> >
> 
> What do you mean by "my use-case"?
> Example?
> 
A NAS that terminates connections of PPP clients (usually transported
over PPPoE or L2TP). Clients may have different routing needs so each
PPP device is created in the appropriate network namespace. Without
rtnl the PPP device has to be created in the PPPoE/L2TP server's
namespace and then moved to the client's one. With rtnl, the PPP device
can be directly created in the right namespace.
