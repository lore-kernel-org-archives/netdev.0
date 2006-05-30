From: James Morris <jmorris@namei.org>
Subject: Re: Refactor Netlink connector?
Date: Tue, 30 May 2006 10:18:32 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605301015090.25929@d.namei>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru>
 <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei>
 <20060528153321.GB31822@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	tgraf@suug.ch, Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:6036 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751502AbWE3OSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 10:18:36 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060528153321.GB31822@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 28 May 2006, Evgeniy Polyakov wrote:

> Does SELinux have security handlers for each type of possible ioctls
> over the world? Each ioctl number is like each netlink type of message,
> but instead there is only one check per ioctl syscall as long as lsm
> hook for socket's send/recv syscall. 
> It could be interesting and quite challenging to force all ioctl users
> to have the same structure under each ioctl number so SELinux could
> control for example disk geometry or time and date requests...

It has a generic control for ioctls, but also does some special handling 
for some ioctls.

> And, btw, what is the purpose of controlling netlink messages?
> Does it prevent malicious userspace application to receive events from
> malicious kernel module?

It provides control over which types of applications can send and receive 
different types of Netlink messages.  e.g. you can specify that Apache can 
read the routing table but not write to it.



- James
-- 
James Morris
<jmorris@namei.org>
