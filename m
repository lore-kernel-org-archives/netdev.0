From: Thomas Graf <tgraf@suug.ch>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 02:39:41 +0100
Message-ID: <20041110013941.GL31969@postel.suug.ch>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41916F0B.5010809@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41916F0B.5010809@trash.net> 2004-11-10 02:29
> Thomas Graf wrote:
> >The action code might load modules in the middle of a classifier
> >configuration and it will be very hard to reverse those changes.
> >Right now we could move it to the top of all configurations and it
> >would probably be possible to get back where we fetch the device
> >but it will get impossible once a classifier requires module
> >loading which is not unlikely.
> > 
> >
> Assuming all error-paths do proper cleanup, returning -EAGAIN
> should always result in the same configuration state as before.

I agree but this assumption is wrong, at least for u32. I agree
that once this is true it would work perfectly fine, however I 
think it would be inefficient to parse the whole TLV tree multiple
times.
