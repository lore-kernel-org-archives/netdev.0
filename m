From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Mon, 19 Feb 2007 15:19:14 +0100
Message-ID: <20070219141914.GD2190@ff.dom.local>
References: <20070217162533.GA22369@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:44589 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932276AbXBSOPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 09:15:52 -0500
Content-Disposition: inline
In-Reply-To: <20070217162533.GA22369@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17-02-2007 17:25, Evgeniy Polyakov wrote:
> On Fri, Feb 16, 2007 at 09:34:27PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
>> Otherwise we can extend select output mask to include hungup too
>> (getting into account that hungup is actually output event).
> 
> This is another possible way to fix select after write after connection
> reset.

I hope you know what you are doing and that this will
change functionality for some users.

In my opinion it looks like a problem with interpretation
and not a bug. From tcp.c:

"
       * Some poll() documentation says that POLLHUP is incompatible
       * with the POLLOUT/POLLWR flags, so somebody should check this
       * all. But careful, it tends to be safer to return too many
       * bits than too few, and you can easily break real applications
       * if you don't tell them that something has hung up!
...
       * Actually, it is interesting to look how Solaris and DUX
       * solve this dilemma. I would prefer, if PULLHUP were maskable,
       * then we could set it on SND_SHUTDOWN. BTW examples given
       * in Stevens' books assume exactly this behaviour, it explains
       * why PULLHUP is incompatible with POLLOUT.    --ANK
       *
       * NOTE. Check for TCP_CLOSE is added. The goal is to prevent
       * blocking on fresh not-connected or disconnected socket. --ANK
       */"

So it seems ANK hesitated and somebody choose not to do
this - maybe for some reason... 

Regards,
Jarek P.
