From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: switching network namespace midway
Date: Wed, 24 Oct 2012 17:21:16 -0400
Message-ID: <20121024212116.GG15034@kvack.org>
References: <CAFaHj6FjDULMCdta3bhVu2mtJeR9TuJVMmbC0H6jjkfb6A5t-Q@mail.gmail.com> <878vavshhp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rsa <ravi.mlists@gmail.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35028 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964884Ab2JXVVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 17:21:20 -0400
Content-Disposition: inline
In-Reply-To: <878vavshhp.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 24, 2012 at 02:11:14PM -0700, Eric W. Biederman wrote:
> rsa <ravi.mlists@gmail.com> writes:
> 
> > Assuming I have a tunnel interface where two route lookups are done --
> > one for innter
> > packet and the other for outer -- do you see any issues in switching
> > the network
> > namespace prior to second route lookup (and restore to the original namespace
> > after the second lookup is done)?
> >
> > If so, are there any other calls other than sk_change_net() needed?
> 
> In general sk_change_net is a bad idea.
> 
> Most likely what you want to do is simply memorize both struct net's
> that you care about and perform the routing lookup as appropriate.
> 
> Certainly you don't want to be calling sk_change_net for every packet
> that goes through your tunnel.

I've actually done this with L2TP.  The packets coming into the system from 
the tunnel are received on one UDP socket in one "struct net", but the 
decapsulated packets are received on a "struct net_device" that is in a 
different "struct net".  No special coding is required -- just move the 
tunnel's net_device into another namespace after creation and it works as 
expected.  Using sk_change_net() would be full of races and is really not 
required for the vast majority of use cases.

		-ben
