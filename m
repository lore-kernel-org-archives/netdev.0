From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 6 Jun 2011 22:06:28 +0200
Message-ID: <201106062206.29134.arnd@arndb.de>
References: <1307389540.2642.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:59046 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793Ab1FFUGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:06:33 -0400
In-Reply-To: <1307389540.2642.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 June 2011 21:45:40 Eric Dumazet wrote:
> While trying Alexander Holler patch, I found a 32bit brctl program was
> not able to work on a 64bit kernel. So I had to switch to another
> machine for my tests.
> 
> brctl addbr mybridge
> ->
> socket(PF_FILE, SOCK_STREAM, 0)         = 3
> ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
> 
> Should we care or not ?
> 

Generally, we try to make all ioctls work in compat mode. For the old
bridge ioctls, this is currently impossible because it uses SIOCPRIVATE
ioctls, but it would be easy to add an ndo_do_compat_ioctl. 

The solution that is documented in net/socket.c is to return 
an invalid version number for BRCTL_VERSION, in the hope that
brctl would switch to the newer interfaces. The new style bridge
ioctls (SIOCBRADDBR, SIOCBRADDIF, ...) are actually supposed to work,
but I've never tried that.

	Arnd
