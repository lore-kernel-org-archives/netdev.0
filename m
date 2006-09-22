From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Fw: [Bugme-new] [Bug 7179] New: Compilation of .tmp_linux1 fails due to missing declaration in net/netfilter/xt_physdev.c
Date: Fri, 22 Sep 2006 11:27:31 +0200
Message-ID: <20060922092731.GC6820@ff.dom.local>
References: <20060921153701.2c49e331.akpm@osdl.org> <20060922084108.GB6820@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:4285 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751103AbWIVJXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 05:23:24 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060922084108.GB6820@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 22, 2006 at 10:41:08AM +0200, Jarek Poplawski wrote:
> On 22-09-2006 00:37, Andrew Morton wrote:
> > Methinks CONFIG_NETFILTER_XT_TARGET_CLASSIFY should depend upon
> > CONFIG_BRIDGE_NETFILTER.  Because brnf_deferred_hooks is defined in
> > net/bridge/br_netfilter.c and is referred to in net/netfilter/xt_physdev.c.
> > 
> > Or something else ;)
> ...
> > I am unsure of which kernel .config parameter is sparking this.  My .config 
> > can be found here: http://www.animeforum.com/jakiao/misato.config
> 
> I don't see CONFIG_BRIDGE set in this misato.config,
> so CONFIG_BRIDGE_NETFILTER was set in some unofficial way.

... or I'm blind! Sorry.

There is CONFIG_BRIDGE=m and this is the source of a problem:
config shouldn't allow for:

CONFIG_NETFILTER_BRIDGE=y 
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y 

Jarek P.
