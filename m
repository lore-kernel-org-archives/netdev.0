From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Refactor Netlink connector?
Date: Sat, 27 May 2006 17:46:31 +0400
Message-ID: <20060527134629.GA16306@2ka.mipt.ru>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52130 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751522AbWE0Nqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 09:46:44 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605261552570.4856@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 26, 2006 at 04:04:53PM -0400, James Morris (jmorris@namei.org) wrote:
> I've been looking through the kernel for new subsytems which might need 
> LSM hooks, and we've got a proliferation of Netlink abstractions: generic 
> Netlink, nfnetlink, connector and kobject_uevent.
> 
> I think we should look at consolidating some of these schemes, and if 
> possible, into a unififed Netlink API.
> 
> As a first step, what would it take to adapt the single user of 
> connector (the w1 driver) to use generic Netlink?

Process accounting, CIFS and OFS netfilter module use it too.
As long as quite a lot of out of the tree projects.

> I suspect that some of the nfnetlink infrastructure can be used more 
> generically, and that a simple API for the common case of kernel->user 
> event notifications could be also be provided.
>
> Thoughts?

I would like to ask, how LSM labeling supposed to work with encapsulated
netlink traffic. Will SELinux (for example) have some rules to allow w1
packets and block other for the same socket type?
And what happens when the same socket start to send packets with
different strucutre or some new protocol will be added? 
Should it consult with SELinux so it updated it's security processing code?

Or LSM supposed to work only on top of socket numbers (which could be
the best) and just control "raw" netlink messages?
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
