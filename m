From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Mon, 14 Feb 2005 19:47:08 -0800
Message-ID: <20050215034708.GG27645@shell0.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net> <420E77FA.6080007@eurodev.net> <20050215001334.GB27645@shell0.pdx.osdl.net> <42115E7E.6050909@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com, davem@davemloft.net,
        jmorris@redhat.com, sds@epoch.ncsc.mil, serue@us.ibm.com
To: Pablo Neira <pablo@eurodev.net>
Content-Disposition: inline
In-Reply-To: <42115E7E.6050909@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pablo Neira (pablo@eurodev.net) wrote:
> Thanks for the explanation. I don't still like so much the new 
> netlink_kernel_create_check function. I think that we could get more 
> variations of netlink_kernel_create in future just to add another 
> feature/checking. So I prefer new function (netlink_kernel_set_check) 

I agree, had the same concern.  I breifly considered an ops struct that
could be passed in during registration so that it could grow a little
easier.

> that set check_sender if it's needed once the netlink socket is created. 
> I've modified your patches to use this function.

Great, thanks.  This is technically racy.  It's possible (albeit small
window) that something could be delivered before this is set.  Using a
callback struct during registration would fix this.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
