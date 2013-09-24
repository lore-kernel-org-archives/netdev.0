From: Cong Wang <amwang@redhat.com>
Subject: Re: [RESEND PATCH iproute2] vxlan: add ipv6 support
Date: Tue, 24 Sep 2013 10:44:05 +0800
Message-ID: <1379990645.19083.9.camel@cr0>
References: <1379730924-12433-1-git-send-email-amwang@redhat.com>
	 <20130923132049.7fa5673e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753275Ab3IXCoP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 22:44:15 -0400
In-Reply-To: <20130923132049.7fa5673e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 13:20 -0700, Stephen Hemminger wrote:
> On Sat, 21 Sep 2013 10:35:24 +0800
> Cong Wang <amwang@redhat.com> wrote:
> 
> > +			if (!inet_pton(AF_INET, *argv, &gaddr)) {
> > +				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
> > +					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
> > +					return -1;
> > +				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
> > +					invarg("invald group address", *argv);
> > +			} else if (!IN_MULTICAST(ntohl(gaddr)))
> > +					invarg("invald group address", *argv);
> 
> This is ugly, can't it be done more generically by checking for ':' in address.
> Or even use getaddrinfo.
> 
> Hate to have lots of special code to handle both address types.
> 

Alright, I will introduce a helper function for it.

Thanks!
