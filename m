From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Tue, 30 May 2006 10:22:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605301019180.25929@d.namei>
References: <Pine.LNX.4.64.0605271223390.12872@d.namei>
 <Pine.LNX.4.64.0605271303050.13104@d.namei>  <20060528153321.GB31822@2ka.mipt.ru>
  <20060528.233649.22498001.davem@davemloft.net> <1148904686.27078.20.camel@jzny2>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, sds@tycho.nsa.gov,
	tgraf@suug.ch, netdev@vger.kernel.org, johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:47773 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751509AbWE3OWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 10:22:47 -0400
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1148904686.27078.20.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 May 2006, jamal wrote:

> If SELinux should provide ways to add "filters" more dynamically at its
> hooks - instead of having people go and look for that table and update
> it then it would simplify things and we may be able to easily have
> netlink users to register such filters at startup; infact we may be able
> to hide this from the users in genetlink. 
> One could argue that if SELinux is capable of adding such filters at its
> hooks, then the problem could be moved to user space policy perhaps? 

This is similar to what the secmark stuff does, allows selection and 
labeling to be done via iptables, so the SELinux kernel stuff then just 
needs to look at the labels.

In this case, I'm not sure it's worthwhile adding a filtering layer to 
Netlink, probably simpler just to have the different Netlink protocols 
define whether each command is one of 'read', 'write' and 'readpriv' (the 
latter is pretty rare), so nothing has to be scanned on the fly at all.


- James
-- 
James Morris
<jmorris@namei.org>
