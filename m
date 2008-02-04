From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: What were the reasons of having mandatory IP address at AX.25
	interfaces ?
Date: Mon, 4 Feb 2008 15:02:52 +0200
Message-ID: <20080204130252.GA2537@mea-ext.zmailer.org>
References: <S3540591AbYBCSQN/20080203181613Z+1592@mail.zmailer.org> <47A60A57.5080402@digitalrealm.net> <20080203202819.GX2537@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:34530 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbYBDNC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 08:02:56 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540060AbYBDNCw (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Mon, 4 Feb 2008 15:02:52 +0200
Content-Disposition: inline
In-Reply-To: <20080203202819.GX2537@mea-ext.zmailer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.. the original reason was apparently that _ifconfig_ blew up
when it saw protocols that it didn't understand on network
interfaces.  Possibly when there was no IP protocol on an
interface.

This happened on DECNET, and apparently on others too.

Thus the  SIOCGIFCONF  ioctl is not returning much else
than interfaces with IP addresses on them, and to get
_all_ interfaces, one must read thru  /proc/net/dev  file.

Some reason like that is possibly behind the reason why
SIOCGIFCONF does not find anything but PF_INET sockets
even when it is run on  PF_AX25 type socket..


The "fun" part is that  ifconfig  does look for all devices
in /proc/net/dev.   Perhaps we should just make all devices
findable with  SIOCGIFCONF regardless of what protocols
they may support ?   And if the  ifconfig  blows up, the
bug is in ifconfig tool, not kernel.

Alternatively one could iterate all network devices of
protocol family X being enabled when  ioctl() is called
on socket with PF_x  (like PF_AX25.)


Can anyone recall any real reason why this would not be
acceptable ?

/Matti Aarnio
