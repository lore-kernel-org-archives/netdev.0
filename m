From: Thomas Graf <tgraf@suug.ch>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 02:22:51 +0100
Message-ID: <20041110012251.GK31969@postel.suug.ch>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <41916A91.3080107@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <41916A91.3080107@trash.net> 2004-11-10 02:10
> Thomas Graf wrote:
> 
> >Sounds reasonable for the sch_api.c and cls_api.c case but
> >will get very nasty for act_api as you noted and any further sub
> >layers that might be added in the future. (The classifier I'm
> >working on is such a case.)
> >
> Can you please show an example of a case where this is needed ?
> Just to help me understand.

The action code might load modules in the middle of a classifier
configuration and it will be very hard to reverse those changes.
Right now we could move it to the top of all configurations and it
would probably be possible to get back where we fetch the device
but it will get impossible once a classifier requires module
loading which is not unlikely.

Well, it's not impossible but it would mean to have the action
code parse the TLV and just try to load the module, then report
to the classifier so it can try to load its own modules and then do
the actual action and classifier configuration. I don't even want to
think of how nasty it gets once a action module requests modules itself ;->
