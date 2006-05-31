From: jamal <hadi@cyberus.ca>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 08:00:03 -0400
Message-ID: <1149076803.5462.36.camel@jzny2>
References: <Pine.LNX.4.64.0605271223390.12872@d.namei>
	 <Pine.LNX.4.64.0605271303050.13104@d.namei>
	 <20060528153321.GB31822@2ka.mipt.ru>
	 <20060528.233649.22498001.davem@davemloft.net>
	 <1148904686.27078.20.camel@jzny2>
	 <Pine.LNX.4.64.0605301019180.25929@d.namei>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org, tgraf@suug.ch,
	sds@tycho.nsa.gov, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:58071 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932479AbWEaMAK
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 08:00:10 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FlPMx-0000FW-8D
	for netdev@vger.kernel.org; Wed, 31 May 2006 08:00:11 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605301019180.25929@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-30-05 at 10:22 -0400, James Morris wrote:
> On Mon, 29 May 2006, jamal wrote:
> 
> > If SELinux should provide ways to add "filters" more dynamically at its
> > hooks - instead of having people go and look for that table and update
[..]
> 
> This is similar to what the secmark stuff does, allows selection and 
> labeling to be done via iptables, so the SELinux kernel stuff then just 
> needs to look at the labels.

hopefully SELinux is taught about such labels semantics at runtime.

> In this case, I'm not sure it's worthwhile adding a filtering layer to 
> Netlink, probably simpler just to have the different Netlink protocols 
> define whether each command is one of 'read', 'write' and 'readpriv' (the 
> latter is pretty rare), so nothing has to be scanned on the fly at all.
> 

We could start by just adding a check for NETLINK_GENERIC in your table
(as is done generally for other netlink families/protocols with SELinux)
and then do the fine-grained stuff. I think that checking for attributes
instead of types will need to be generic for all of netlink.
Thomas?

cheers,
jamal

