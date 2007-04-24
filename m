From: "Laurent Chavey" <chavey@google.com>
Subject: Re: is CONFIG_NET_CLS_ACT always set ?
Date: Tue, 24 Apr 2007 16:03:41 -0700
Message-ID: <97949e3e0704241603v6cf67e48k384f533c9dd29714@mail.gmail.com>
References: <97949e3e0704231419o21062b6cl5b8cf38e1b412b05@mail.gmail.com>
	 <1177369190.4096.13.camel@localhost>
	 <97949e3e0704231608n6f43807en1ee6e27265c641ba@mail.gmail.com>
	 <1177372977.4096.24.camel@localhost>
	 <97949e3e0704241333q3ce1cc88t314cba84fc9f9bab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:58768 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423204AbXDXXDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 19:03:50 -0400
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id l3ON3jgY016803
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 00:03:45 +0100
Received: from ik-out-1112.google.com (ikac30.prod.google.com [10.68.54.30])
	by spaceape12.eur.corp.google.com with ESMTP id l3ON3fcI007069
	for <netdev@vger.kernel.org>; Wed, 25 Apr 2007 00:03:41 +0100
Received: by ik-out-1112.google.com with SMTP id c30so14232ika
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2007 16:03:41 -0700 (PDT)
In-Reply-To: <97949e3e0704241333q3ce1cc88t314cba84fc9f9bab@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

handle_bridge does call the tap, so my question is answer there.
thanks,

On 4/24/07, Laurent Chavey <chavey@google.com> wrote:
> On 4/23/07, jamal <hadi@cyberus.ca> wrote:
> > On Mon, 2007-23-04 at 16:08 -0700, Laurent Chavey wrote:
> > > sorry for the trick question.
> > >
> > > I was simply making a modification to the skb tap code
> > > to allow tcpdump to work on the slave interface and not
> > > just the bonded one.
> >
> > If you dont mind: what is the goal? I am not sure i want to see the
> > packets on a backup interface in a bond active/backup - but you may
> > have some good reason.
> this is for an lacp type bond where packets can come on
> any of the bond links and we need to check for the exact link.
>
> >
> > > The code change requires a change to
> > > the for loop code and it follow on to the call to deliver_skb().
> > >
> >
> > Iam assuming you have taken care of the code above that which drops the
> > packet if not destined for master?
> yes
> >
> > > In the process of adding the code, I noticed that if (at least
> > > that is how I read the code)
> > > CONFIG_NET_CLS_ACT is not defined then
> > > the last pt_prev is call after the diverter and bridge code
> > > have handled the skb.  This would only occur for bridged skb
> > > that one wanted to tap.
> > >
> >
> > The bridge code does the right thing if you follow handle bridge.
> > The old diverter (you must be looking at an old kernel, because it is
> > gone) was supposed to be able to steal packets.
> > I am not sure if that answers your question.
> >
> given 2 skb, both bridged (stolen) by the bridge code,
> if CONFIG_NET_CLS_ACT is not defined, then it looks like that
> only the first skb would be taped, the second one never makes
> it to the tap.
>
>
> > cheers,
> > jamal
> >
> >
> >
>
