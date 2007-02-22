From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write
 returned ECONNRESET
Date: Wed, 21 Feb 2007 22:47:06 -0800 (PST)
Message-ID: <20070221.224706.35017492.davem@davemloft.net>
References: <20070216102914.7d4b34f0@freekitty>
	<20070216183426.GA3138@2ka.mipt.ru>
	<20070217162533.GA22369@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751434AbXBVGrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 01:47:08 -0500
In-Reply-To: <20070217162533.GA22369@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Sat, 17 Feb 2007 19:25:33 +0300

> On Fri, Feb 16, 2007 at 09:34:27PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Otherwise we can extend select output mask to include hungup too
> > (getting into account that hungup is actually output event).
> 
> This is another possible way to fix select after write after connection
> reset.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
 ...
>  #define POLLIN_SET (POLLRDNORM | POLLRDBAND | POLLIN | POLLHUP | POLLERR)
> -#define POLLOUT_SET (POLLWRBAND | POLLWRNORM | POLLOUT | POLLERR)
> +#define POLLOUT_SET (POLLWRBAND | POLLWRNORM | POLLOUT | POLLERR | POLLHUP)
>  #define POLLEX_SET (POLLPRI)

POLLHUP is absolutely not maskable, this is very deeply entrenched
in the poll() semantics and definitions.
