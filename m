From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 12/12] [RFC] can: avoid using timeval for uapi
Date: Tue, 06 Oct 2015 11:18:08 +0200
Message-ID: <6130832.516TFPqmA3@wuerfel>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de> <7548522.iLToS4O3HD@wuerfel> <56138EDC.8080501@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	y2038@lists.linaro.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, linux-can@vger.kernel.org,
	linux-api@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:58867 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479AbbJFJSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 05:18:25 -0400
In-Reply-To: <56138EDC.8080501@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 October 2015 11:05:32 Marc Kleine-Budde wrote:
> On 10/06/2015 10:32 AM, Arnd Bergmann wrote:
> > On Monday 05 October 2015 20:51:08 Oliver Hartkopp wrote:
> >>
> >> I double checked some (more) BCM applications I have access to.
> >>
> >> E.g. https://github.com/linux-can/can-tests
> >>
> >> When you do a 'git grep ival1' there you get something like
> >>
> >> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_sec = 1;
> >> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_usec = 0;
> >> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_sec = 0;
> >> tst-bcm-cycle.c:        msg.msg_head.ival1.tv_usec = 0;
> >> tst-bcm-dump.c: msg.msg_head.ival1.tv_sec       = timeout / 1000000;
> >> tst-bcm-dump.c: msg.msg_head.ival1.tv_usec      = timeout % 1000000;
> >> (..)
> >>
> >> So the usual way to assign values to ival1 and ival2 is NOT to assign an
> >> existing struct timeval but to directly assign its tv_[u]sec elements.
> > 
> > Ok, very good.
> > 
> >> I applied your bcm.h changes to my local can-tests tree and it compiles
> >> without any problems - as expected. I don't see any serious drawback with your
> >> idea. I wonder whether developers would ever notice this change ...
> >>
> >>> We could address problem a) by using '__u32' or 'int' members
> >>> rather than 'long', but that would have a more significant
> >>> downside in also breaking support for all existing 64-bit user
> >>> binaries that might be using this interface, which is likely
> >>> not acceptable.
> >>
> >> Indeed.
> >>
> >>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> >>> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
> >>
> >> Thanks for your good suggestion to make the BCM API y2038 proof!
> >>
> >> Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>
> > 
> > Thanks.
> > 
> > What is the normal path for CAN patches? Should I resend with your
> > Ack and without the RFC for Marc to pick it up?
> 
> You can add my:
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> add upstream the 2038 fixes as a block.

Davem already picked up the first 10 of the series. If you don't
mind, I'd prefer if you could take this one into your tree so I
have it off my list.
I have 200 other patches in various states and more getting added.

	Arnd
