From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/3] NET: Generic rate estimator
Date: Mon, 4 Oct 2004 16:15:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004141532.GB15898@postel.suug.ch>
References: <20041003213124.GG14344@postel.suug.ch> <20041003213954.GI14344@postel.suug.ch> <20041003161436.50293f9a.davem@davemloft.net> <20041003233647.GN14344@postel.suug.ch> <1096852582.1046.378.camel@jzny.localdomain> <20041004125300.GA15898@postel.suug.ch> <1096896256.1072.4.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1096896256.1072.4.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1096896256.1072.4.camel@jzny.localdomain> 2004-10-04 09:24
> What you need is to replace the HZ/4 in the creation and execution
> of the timer with a constant. And that the value of said constant would
> be preferably in the 250ms range.

HZ/4 == 250ms works except for HZ=122 (~246ms) and HZ=50 (~240ms). I don't
know how you think it is possible to find a constant around 250ms which
works for all HZ values. The problem gets even minor if we do
(HZ<<idx)/4 instead of (HZ/4)<<idx in which the inaccuracy only happens
if idx is 0, i.e. interval == -2. 
