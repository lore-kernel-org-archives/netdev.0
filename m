From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Fri, 19 May 2006 12:00:46 +0200
Message-ID: <200605191200.47132.arnd@arndb.de>
References: <20060517220218.GA13411@myri.com> <200605190355.11230.arnd@arndb.de> <446D2CA7.2070009@myri.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.188]:28358 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751326AbWESKA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 06:00:57 -0400
To: Brice Goglin <brice@myri.com>
In-Reply-To: <446D2CA7.2070009@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 19 May 2006 04:25, Brice Goglin wrote:
> dev_mc_upload() from net/core/dev_mcast.c does
> 
> spin_lock_bh(&dev->xmit_lock);
> __dev_mc_upload(dev);
> 
> which calls dev->set_multicast_list(), which is
> myri10ge_set_multicast_list()
> 
> which calls myri10ge_change_promisc
> 
> which calls myri10ge_send_cmd

Hmm, if that is the only path where you call it, it may be
helpful to change myri10ge_change_promisc to call a special
atomic version of myri10ge_send_cmd then, while all others
use the regular version, which you can then convert to
do msleep as well.

	Arnd <><
