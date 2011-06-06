From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 6 Jun 2011 22:26:02 +0200
Message-ID: <201106062226.02635.arnd@arndb.de>
References: <1307389540.2642.3.camel@edumazet-laptop> <201106062206.29134.arnd@arndb.de> <1307391174.2642.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:50229 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834Ab1FFU0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:26:04 -0400
In-Reply-To: <1307391174.2642.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 06 June 2011 22:12:54 Eric Dumazet wrote:
> So for an old binary, compiled at the time SIOCBRADDBR wasnt there (in
> include file I mean), we ended doing :
> 
>         {
>                 char _br[IFNAMSIZ];
>                 unsigned long arg[3]
>                         = { BRCTL_ADD_BRIDGE, (unsigned long) _br };
> 
>                 strncpy(_br, brname, IFNAMSIZ);
>                 ret = ioctl(br_socket_fd, SIOCSIFBR, arg);
>         }
> 
> And this breaks on 64bit kernel

Ah, you were quicker than me at posting this ;-)

> I guess we shall add some logic in kernel to support SIOCSIFBR
> afterall ;)
> 
> Thanks !
> 
> BTW: I confirm that compiling an up2date 32bit brctl with an up2date
> include files is OK on 64bit kernel.

I did a little more digging in the history and found that the code in
brctl was added in this commit:

commit 328f4711bbc369dcccf8f8cfba2adf5dd0f74479
Author: shemminger <shemminger>
Date:   Fri May 21 17:41:48 2004 +0000

    New version of command and library that use sysfs.
    Update make system to build with or without sysfs.

It's not completely clear to me if it's worth supporting older
user space than this, but it's certainly possible.

	Arnd
