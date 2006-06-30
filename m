From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 19:34:38 +0200
Message-ID: <20060630173438.GJ14627@postel.suug.ch>
References: <20060629233933.GB14627@postel.suug.ch> <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch> <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch> <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch> <1151687977.5270.91.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60345 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932828AbWF3ReR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 13:34:17 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151687977.5270.91.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-06-30 13:19
> On Fri, 2006-30-06 at 18:32 +0200, Thomas Graf wrote:
> > * jamal <hadi@cyberus.ca> 2006-06-30 10:35
>  
> > > Did you actually try to run this before you reached this conclusion?
> > 
> > I did, fortunately some other bug prevents this from happening,
> > packets are simply dropped somewhere.
> > 
> 
> It is not a bug, Thomas! I am getting a little frustrated now.
> The packets will be dropped because we set the at field to zero which is
> invalid. That is done on purpose. It is only meaningful for ifb. The
> challenge is much bigger than it appears. You could end up deadlocking
> on the tx lock. So this was the choice i had to make.

Please explain, tc_verd is reset in the tasklet after dequeueing and set
again in dev_queue_xmit(). ifb_xmit will always see a valid tc_verd
at egress.
