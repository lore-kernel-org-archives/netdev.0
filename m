From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: add userspace example code into Documentation/connector/
Date: Fri, 25 Aug 2006 11:05:27 +0400
Message-ID: <20060825070527.GB1816@2ka.mipt.ru>
References: <20060825064956.GA20468@2ka.mipt.ru> <44EE9F53.2090303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:33177 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750929AbWHYHFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 03:05:41 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44EE9F53.2090303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 25, 2006 at 08:57:23AM +0200, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> > Hello.
> > 
> > I was asked several times to include userspace example code into
> > Documentation, so if there is no policy against it, consider attached patch 
> > for 2.6.18. This program works with included Documentation/connector/cn_test.c 
> > connector module.
> 
> > +	l_local.nl_family = AF_NETLINK;
> > +	l_local.nl_groups = 0x123;
> > +	l_local.nl_pid = 0;
> > +
> > +	if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) == -1) {
> > +		perror("bind");
> > +		close(s);
> > +		return -1;
> > +	}
> > +
> > +	{
> > +		int on = l_local.nl_groups;
> > +		setsockopt(s, 270, 1, &on, sizeof(on));
> > +	}
> 
> Example code shouldn't use magic numbers, please use the proper defines.
> And the code is wrong, using the same group number for bind (which takes
> a bitmask) and setsockopt (which takes a group number) doesn't work.
> Its not necessary to use setsockopt if you already used bind anyway.

I put there explicit socket option to show how it works in case there
will be several group requests, which will not be placed into initial
bind call.
But you are right, that magic numbers are not that good.
I will update program with appropriate changes.
Thank you.

-- 
	Evgeniy Polyakov
