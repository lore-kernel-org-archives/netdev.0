From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: Allow group ownership of TUN/TAP devices.
Date: Mon, 02 Feb 2009 17:44:34 +0300
Message-ID: <498706D2.5070003@msgid.tls.msk.ru>
References: <498700CD.2030403@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010009060800090606030100"
Cc: Guido Guenther <agx@sigxcpu.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:24439 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751106AbZBBOoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 09:44:37 -0500
In-Reply-To: <498700CD.2030403@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010009060800090606030100
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Michael Tokarev wrote:
[]
> 2, and this is the main one: How about supplementary groups?
> 
> Here I have a valid usage case: a group of testers running various
> versions of windows using KVM (kernel virtual machine), 1 at a time,
> to test some software.  kvm is set up to use bridge with a tap device
> (there should be a way to connect to the machine).  Anyone on that group
> has to be able to start/stop the virtual machines.
> 
> My first attempt - pretty obvious when I saw -g option of tunctl - is
> to add group ownership for the tun device and add a supplementary group
> to each user (their primary group should be different).  But that fails,
> since kernel only checks for egid, not any other group ids.
> 
> What's the reasoning to not allow supplementary groups and to only check
> for egid?

Like this.

Signed-off-by: Michael Tokarev <mjt@tls.msk.ru>

Thanks!

/mjt


--------------010009060800090606030100
Content-Type: text/x-patch;
 name="tun-allow-supplementary-groups.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tun-allow-supplementary-groups.diff"

--- linux-2.6.28/drivers/net/tun.c.orig	2008-12-25 02:26:37.000000000 +0300
+++ linux-2.6.28/drivers/net/tun.c	2009-02-02 17:33:02.000000000 +0300
@@ -714,7 +714,7 @@ static int tun_set_iff(struct net *net, 
 		if (((tun->owner != -1 &&
 		      current->euid != tun->owner) ||
 		     (tun->group != -1 &&
-		      current->egid != tun->group)) &&
+		      !in_egroup_p(tun->group))) &&
 		     !capable(CAP_NET_ADMIN))
 			return -EPERM;
 	}

--------------010009060800090606030100--
