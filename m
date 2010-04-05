From: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Subject: RE: CAIF device
Date: Mon, 5 Apr 2010 13:19:14 +0200
Message-ID: <81C3A93C17462B4BBD7E272753C105791696B5DCF0@EXDCVYMBSTM005.EQ1STM.local>
References: <20100401160916.2a2574f4@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alan <alan@lxorguk.ukuu.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:56586 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751786Ab0DELTl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Apr 2010 07:19:41 -0400
In-Reply-To: <20100401160916.2a2574f4@lxorguk.ukuu.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan.

Alan wrote:
> I was reading through the CAIF code and I noticed a couple of bugs
> 
> Doesn't check there is a write method so set on a read only
> device it's not good news (doubly so as there seem to be no
> permission checks ?) plus no permissions checks and also the
> following which looks unsafe
> 
>         dev_close(ser->dev);
>         unregister_netdevice(ser->dev);
>         list_del(&ser->node);
>         debugfs_deinit(ser);
> 
> Now ser is the netdev private data so what stops it going away when
> unregister_netdev is called ?

I think this should work fine as the unregistration of the ser->dev is done after rtnl_lock,
this delays the freeing of the device until rtnl_unlock.
> 
> Secondly tty devices are ref counted and this for some reason didn't
> get fixed in the driver yet.
> 
> [Patches to follow for the write and kref bugs, the others need the
> authors and someone who knows the netdev code these days to fix]

Thanks, looking forward to review your patches.

BR/Sjur
