From: Michael Tokarev <mjt@tls.msk.ru>
Subject: re: Allow group ownership of TUN/TAP devices.
Date: Mon, 02 Feb 2009 17:18:53 +0300
Message-ID: <498700CD.2030403@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, Guido Guenther <agx@sigxcpu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:23691 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751729AbZBBOS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 09:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.  Just noticed an old commit 8c644623fe7e41f59fe97cdf666cba3cb7ced7d8
dated Mon Jul 2 22:50:25 2007 -0700 that allows group ownership for
tun/tap devices.  Here's the comment:

    [NET]: Allow group ownership of TUN/TAP devices.

    Introduce a new syscall TUNSETGROUP for group ownership setting of tap
    devices. The user now is allowed to send packages if either his euid or
    his egid matches the one specified via tunctl (via -u or -g
    respecitvely). If both, gid and uid, are set via tunctl, both have to
    match.

Two questions:

1: why both has to match?  Is it really useful?
 (I understand it's a corner case, somehow)

2, and this is the main one: How about supplementary groups?

Here I have a valid usage case: a group of testers running various
versions of windows using KVM (kernel virtual machine), 1 at a time,
to test some software.  kvm is set up to use bridge with a tap device
(there should be a way to connect to the machine).  Anyone on that group
has to be able to start/stop the virtual machines.

My first attempt - pretty obvious when I saw -g option of tunctl - is
to add group ownership for the tun device and add a supplementary group
to each user (their primary group should be different).  But that fails,
since kernel only checks for egid, not any other group ids.

What's the reasoning to not allow supplementary groups and to only check
for egid?

Thanks!

/mjt
