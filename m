From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Fri, 11 May 2007 06:59:08 +1200
Message-ID: <5640c7e00705101159w68750a47xc06495e4395de583@mail.gmail.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>
	 <46435412.50800@hp.com> <464360D6.4080402@hp.com>
	 <46436274.4060804@hp.com> <4643654F.5060207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.229]:39761 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756669AbXEJS7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 14:59:10 -0400
Received: by wr-out-0506.google.com with SMTP id 76so757280wra
        for <netdev@vger.kernel.org>; Thu, 10 May 2007 11:59:09 -0700 (PDT)
In-Reply-To: <4643654F.5060207@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/11/07, Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> >> May be for TCP?  What about other protocols?
> >
> > There are other protocols?-)  True, UDP, and I suppose certain modes of
> > SCTP might be sending streams of small packets, as might TCP with
> > TCP_NODELAY set.
> >
> > Do they often queue-up outside the driver?
>
> Not sure if DCCP might fall into this category as well...
>
Yes DCCP definitely can queue outside the driver.

> I think the idea of this patch is gather some number of these small packets and
> shove them at the driver in one go instead of each small packet at a time.
>
> I might be helpful, but reserve judgment till I see more numbers.
>
> -vlad

As I see this proposed patch it is about reducing the number of "task
switches" between the driver and the protocol. I use task switch in
speech marks as it isn't really as is in the kernel. So in other words
we are hoping that spending more time in each area would keep the
cache hot and work to be done if locks held. This of course requires
that the complexity added doesn't outweigh the gains - otherwise you
could end up in a worse scenario where the driver doesn't send packets
because the protocol is busy linking them.

As far as I can tell you're not combining packets?? This would
definitely break UDP/DCCP which are datagram based.

Will be interesting to see results but I'm a little sceptical.

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
