From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net] uapi: fix compatability of linux/in.h with
 netinet/in.h
Date: Mon, 29 Jun 2015 14:55:48 -1000
Message-ID: <20150629145548.4169cf9d@uryu.home.lan>
References: <20150625231206.4a9c3daf@uryu.home.lan>
	<20150629180720.GA22584@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33375 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbbF3Azz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 20:55:55 -0400
Received: by igcur8 with SMTP id ur8so51143048igc.0
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 17:55:54 -0700 (PDT)
In-Reply-To: <20150629180720.GA22584@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Jun 2015 20:07:20 +0200
Pablo Neira Ayuso <pablo@netfilter.org> wrote:

> On Thu, Jun 25, 2015 at 11:12:06PM -0400, Stephen Hemminger wrote:
> > This fixes breakage to iproute2 build with recent kernel headers
> > caused by:
> >    commit a263653ed798216c0069922d7b5237ca49436007
> >    Author: Pablo Neira Ayuso <pablo@netfilter.org>
> >    Date:   Wed Jun 17 10:28:27 2015 -0500
> > 
> >    netfilter: don't pull include/linux/netfilter.h from netns headers
> > 
> > The issue is that definitions in linux/in.h overlap with those
> > in netinet/in.h. This patch solves this by introducing the same
> > mechanism as was used to solve the same problem with linux/in6.h
> 
> My patch also modifies non-exposed net/netns/ headers, I'm not sure
> how this can be causing problems to uapi headers.

The problem is that your patch changes include/uapi/linux/netfilter.h
to include linux/in.h. Some programs have already include <netinet/in.h>
(often through a complex chain of headers).
If both headers are included it causes errors and warnings about duplicate
definitions. My patch fixes that.
