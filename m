From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 14:21:25 +0300
Message-ID: <20090130112125.GA9908@ioremap.net>
References: <20090128212114.38be3e8c@extreme> <20090129103544.GC22110@redhat.com> <20090129213549.7fadfa2e@extreme> <20090130081600.GA2717@ioremap.net> <20090130102749.GC1052@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Fedora/Linux Management Tools <et-mgmt-tools@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Daniel P. Berrange" <berrange@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:41772 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbZA3LVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 06:21:38 -0500
Content-Disposition: inline
In-Reply-To: <20090130102749.GC1052@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 10:27:49AM +0000, Daniel P. Berrange (berrange@redhat.com) wrote:
> The virt-manager console is basically just a plain old boring VNC client.
> It uses GTK-VNC to establish its VNC network connection, and that doesn't
> do anything unusual AFAIK. We use getaddrinfo() to resolve the hostname,
> and then try each of its results in turn, until we succesfully connect
> to the VNC server. We don't explicitly bind() to the client port, just
> let the kernel pick it for us. The code in question, is the "gvnc_open_host"
> method from gvnc.c,  which starts at about line 2910
> 
> http://freehg.org/u/aliguori/gtk-vnc.hg/file/d68935d582f0/src/gvnc.c

So it is not explicit bind call, but port autoselection in the
connect(). Can you check what errno is returned?
Did I understand it right, that connect fails, you try different
address, but then suddenly all those sockets become 'alive'?

-- 
	Evgeniy Polyakov
