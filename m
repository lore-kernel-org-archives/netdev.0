From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 16:09:51 +0100
Message-ID: <1421161791.13626.33.camel@redhat.com>
References: <54B4A7E4.7030301@gmail.com> <20150112231021.316648e3@urahara>
	 <1421145346.13626.12.camel@redhat.com> <54B50873.4090907@miraclelinux.com>
	 <54B50C71.7090007@miraclelinux.com> <1421152613.13626.24.camel@redhat.com>
	 <54B53187.7080306@gmail.com> <20150113150048.GA28371@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49836 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752277AbbAMPKD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 10:10:03 -0500
In-Reply-To: <20150113150048.GA28371@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-13 at 10:00 -0500, Sowmini Varadhan wrote:
> On (01/13/15 07:53), David Ahern wrote:
> > 
> > The current code seems inconsistent: I can put an IPv6 address on a
> > link in the down state. On a link up the address is retained. Only
> > on a subsequent link down is it removed. If DAD or anything else is
> > the reason for the current logic then why allow an address to be
> > assigned in the down state? Similarly that it currently seems to
> > work ok then it suggests the right thing is done on a link up in
> > which case a flush is not needed.
> > 
> > Bottom line is there a harm in removing the flush? If there is no
> > harm will mainline kernel take a patch to do that or is your
> > backward compatibility concern enough to block it?
> 
> Does some of this have to do with the manner in which this interacts
> with SLAAC? I recall that there were two schools of thought for doing
> DAD when SLAAC is present: one says it is sufficient to just do DAD
> on the interface-id, the other requies DAD on the whole 128-bit IPv6
> address. I'm not sure which choice linux makes.

Yes, it does have something to do with it. But I didn't understand what
you meant by doing DAD on the interface-id.

If you look at the patches I just posted, only addresses which are in
link-local and not in permanent state will be flushed.

I also need to do research on how to safely approach this, I don't know,
yet.

Bye,
Hannes
