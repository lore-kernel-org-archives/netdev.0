From: Thomas Graf <tgraf@suug.ch>
Subject: Re: patch: Action repeat
Date: Wed, 4 May 2005 16:05:40 +0200
Message-ID: <20050504140540.GE18452@postel.suug.ch>
References: <20050430235809.GI577@postel.suug.ch> <1115035838.8929.236.camel@localhost.localdomain> <20050502150632.GM577@postel.suug.ch> <1115207194.7665.109.camel@localhost.localdomain> <20050504123157.GA18452@postel.suug.ch> <1115211549.7665.140.camel@localhost.localdomain> <20050504132822.GB18452@postel.suug.ch> <1115213600.7665.166.camel@localhost.localdomain> <20050504134815.GD18452@postel.suug.ch> <1115214782.7665.184.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115214782.7665.184.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1115214782.7665.184.camel@localhost.localdomain> 2005-05-04 09:53
> On Wed, 2005-04-05 at 15:48 +0200, Thomas Graf wrote:
> > * jamal <1115213600.7665.166.camel@localhost.localdomain> 2005-05-04 09:33
> 
> > > in skb_clone() and friends.
> > > Look at CONFIG_NET_CLS_ACT in net/core/skbuff.c
> > 
> > Yes this solves the case for dummy devices etc but how would
> > this cause a reset on the way from ingress to egress?
> 
> If the verdict is not to reset, there should be no clearing of those
> fields from ingress -> egress until the skb is either freed or someone
> else along the path resets it. Cloning or copying inherits. Am i missing
> something?

I guess not but we might have a different understanding of when to
reset. From my point of view the only reason to reset any meta data
is to provide a certain scope a set of new fresh and clean sheets
to play around. Assuming we define global as everything and local
as per device/(ingress|egress) then we definitely need to invoke
a reset on the way over to egress. 
