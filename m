From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][RFC] Security marking
Date: Mon, 17 Apr 2006 19:51:54 +0200
Message-ID: <4443D5BA.6060605@trash.net>
References: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32968 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751186AbWDQRv4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 13:51:56 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> Last year, I posted a set of patches to allow iptables matching against 
> associated processes for incoming packets.  With this patch, I'm proposing 
> a much simpler alternative and solictiting feedback on the idea from other 
> networking developers.
> 
> For the original patches and discussion, see:
> http://marc.theaimsgroup.com/?l=linux-netdev&m=113027175208707&w=2
> and
> http://people.redhat.com/jmorris/selinux/skfilter/
> 
> The purpose of the patches was to allow incoming owner matching to work 
> cleanly, as well as allow integration of SELinux and Netfilter apps 
> (iptables, conntrack etc).  This would also allow the existing SELinux 
> networking hooks to be replaced in a more powerful and expressive way.
> 
> The skfilter patches posted are quite invasive, and probably require 
> moving all Netfilter 'input' processing to the socket layer, with several 
> unresolved issues.

Moving the netfilter input processing to the socket layer would actually
be a nice solution in my opinion, but its unfortunately not possible
without changing user-visible behaviour. SNAT is performed in LOCAL_IN
before filtering, but we need the already SNATed packet for the
socket lookup. So I concluded that the only possibility is to keep the
existing hooks and have a seperate skfilter INPUT chain. The conntrack
confirmation problem can be solved by registering the ip_confirm hook
with the socket hooks when they are compiled in.

>From a pure netfilter POV it would still be nice to have the socket
hooks for userspace queueing in socket context and filtering hard
to track protocols. My only question is: if I would port the skfilter
patches to the current kernel today and fix the unresolved issues,
would you still prefer this approach?

