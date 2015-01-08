From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route/max_size sysctl in ipv4
Date: Wed, 07 Jan 2015 18:19:54 -0800
Message-ID: <1420683594.5947.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAOxq_8NdxBScZ182bXs5KmTZLKRMeF3AVt+DJNFUff42gaZG4w@mail.gmail.com>
	 <20150105.193614.1827024424476781168.davem@davemloft.net>
	 <CAOxq_8OtQ0WD-PKBd4kX0JwZiaStqJ-cQiQRhWnTAK9Q0JquxA@mail.gmail.com>
	 <20150105.195128.794605376092864881.davem@davemloft.net>
	 <CAOxq_8MoPocarmhdXQOkc=4HfGh1L+5-ozEdwPzn2K8q4Gh55w@mail.gmail.com>
	 <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ani Sinha <ani@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:59020 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752441AbbAHCT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 21:19:57 -0500
Received: by mail-qg0-f48.google.com with SMTP id j5so380418qga.7
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 18:19:57 -0800 (PST)
In-Reply-To: <CAOxq_8PeZFGGsHoT7Ef0gJezV=UikMQqM0UvQZQcpOywxBOy4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-07 at 17:25 -0800, Ani Sinha wrote:
> hey guys,
> 
> On Tue, Jan 6, 2015 at 5:56 PM, Ani Sinha <ani@arista.com> wrote:
> > On Mon, Jan 5, 2015 at 4:51 PM, David Miller <davem@davemloft.net> wrote:
> >
> >> The sysctl is kept so that scripts reading it don't suddenly stop
> >> working.  We can't just remove sysctl values.
> >
> > Interestingly, one of our scripts did break. It broke because now this
> > sysctl is only available in the global net namespace and not in the
> > child namespaces. If not breaking scripts is the fundamental logic in
> > keeping in sysctl intact, would you guys be open to accepting a patch
> > where we make this sysctl available for all net namespaces?
> 
> Any thoughts on this?

AFAIK, this sysctl (and others) always have been global.

Only /proc/sys/net/ipv4/route/flush is per ns

namespaces usage can indeed remove some sysctl :
Only initial namespace show them.

Presumably the global sysctl could be shadowed as read only, but still
some scripts expecting them being rw would break anyway.
