From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: add ipv6 support
Date: Fri, 19 Apr 2013 08:26:23 -0700
Message-ID: <20130419082623.0bc17afc@nehalam.linuxnetplumber.net>
References: <1366175423-27310-1-git-send-email-amwang@redhat.com>
	<1366175423-27310-7-git-send-email-amwang@redhat.com>
	<20130418155703.251298c3@nehalam.linuxnetplumber.net>
	<1366381212.5117.23.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f44.google.com ([209.85.210.44]:55271 "EHLO
	mail-da0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030512Ab3DSP04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:26:56 -0400
Received: by mail-da0-f44.google.com with SMTP id z20so2017072dae.3
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 08:26:56 -0700 (PDT)
In-Reply-To: <1366381212.5117.23.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Apr 2013 22:20:12 +0800
Cong Wang <amwang@redhat.com> wrote:

> On Thu, 2013-04-18 at 15:57 -0700, Stephen Hemminger wrote:
> > On Wed, 17 Apr 2013 13:10:23 +0800
> > Cong Wang <amwang@redhat.com> wrote:
> > 
> > > +			if (!inet_pton(AF_INET, *argv, &gaddr)) {
> > > +				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
> > > +					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
> > > +					return -1;
> > > +				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
> > > +					invarg("invald group address", *argv);
> > > +			} else if (!IN_MULTICAST(ntohl(gaddr)))
> > > +					invarg("invald group address", *argv);
> > 
> > Maybe using getaddrinfo would be better to allow symbolic names as well?
> 
> Yes, but I don't think many people use symbolic name for a multicast
> group?
> 
> Thanks.
> 

You can use AI_NUMERICHOST to avoid symbolic names.
