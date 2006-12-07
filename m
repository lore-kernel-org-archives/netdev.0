From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: NAPI and shared interrupt control
Date: Thu, 7 Dec 2006 02:15:55 -0800
Message-ID: <20061207101555.GB19479@gate.ebshome.net>
References: <1165465446.5469.189.camel@localhost.localdomain> <20061207.011627.43485384.davem@davemloft.net> <20061207094502.GA19479@gate.ebshome.net> <20061207.015954.52181319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.ebshome.net ([208.106.21.240]:47955 "EHLO gate.ebshome.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031964AbWLGKPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 05:15:55 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061207.015954.52181319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 07, 2006 at 01:59:54AM -0800, David Miller wrote:
> From: Eugene Surovegin <ebs@ebshome.net>
> Date: Thu, 7 Dec 2006 01:45:02 -0800
> 
> > I fail to see how this is not even more ugly and more complex than the 
> > solution we have right now. Instead of trivial "orthogonal" polling 
> > code you are suggesting adding additional complexity - handle 
> > dynamic selection of that "master" EMAC and also handling situation 
> > when this master device goes down and you have to switch to 
> > another one without disturbing polling for other active devices. Why 
> > all this? This hw is ugly enough as it is.
> 
> Don't do dynamic selection, that indeed would be dumb.
> 
> Instead, just pick one of them to act as the polling master.
> Each EMAC has a backpointer to the master EMAC, and trigger
> the poll via that indirection.

Well, dev_close() explicitly checks and modifies state bits related 
to NAPI polling. From quick look I don't think it's safe to take down 
"master" device and expect NAPI polling to still work.

> 
> With this shared interrupt scheme and lack of hw interrupt
> mitigation, how did the designers of this chip expect people
> to do interrupt mitigation?  I suppose they expected you to
> do it by standing on your head :-)

There are more fun stuff in this hw - max buffer size is around 4080 
bytes so we have to split packets on TX and assemble on RX (meaning 
doing memcpy) for jumbo frames. You have to reset MAC on almost every 
register change, etc

-- 
Eugene

