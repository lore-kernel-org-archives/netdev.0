From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: Re: [PATCH] allow nf_tproxy_core module to unload
Date: Mon, 21 Dec 2009 08:12:21 +0100
Message-ID: <1261379541.11300.6.camel@nessa.odu>
References: <20091218162440.22480.3383.sendpatchset@localhost.localdomain>
 <20091218.194146.104066031.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7BIT
Cc: DavidMiller <davem@davemloft.net>, netdev@vger.kernel.org,
	sassmann@redhat.com, netfilter-devel@vger.kernel.org
To: emcnabb@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20091218.194146.104066031.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, 2009-12-18 at 19:41 -0800, David Miller wrote:
> From: Evan McNabb <emcnabb@redhat.com>
> Date: Fri, 18 Dec 2009 11:24:40 -0500
> 
> > From: Evan McNabb <emcnabb@redhat.com>
> > 
> > Include exit function so nf_tproxy_core module can be removed.
> > 
> > Signed-off-by: Evan McNabb <emcnabb@redhat.com>
> 
> netfilter-devel is the best place to CC: netfilter
> patches, added...
> 
> > 
> > diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
> > index 5490fc3..ec6737c 100644
> > --- a/net/netfilter/nf_tproxy_core.c
> > +++ b/net/netfilter/nf_tproxy_core.c
> > @@ -89,7 +89,12 @@ static int __init nf_tproxy_init(void)
> >  	return 0;
> >  }
> >  
> > +static void __exit nf_tproxy_exit(void)
> > +{
> > +}
> > +
> >  module_init(nf_tproxy_init);
> > +module_exit(nf_tproxy_exit);
> >  
> >  MODULE_LICENSE("GPL");
> >  MODULE_AUTHOR("Krisztian Kovacs");

I'm afraid it's not that simple...

tproxy sets skb->destructor to nf_tproxy_destructor for certain
(redirected) skbs. You must make sure that no skbs have their destructor
set to that function before removing the module.

Cheers,
Krisztian


