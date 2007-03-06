From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Tue, 6 Mar 2007 09:13:16 -0800
Message-ID: <20070306171316.GA19669@bougret.hpl.hp.com>
References: <1173144447.15891.93.camel@johannes.berg>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Jean Tourrilhes <jt@hpl.hp.com>,
	Dan Williams <dcbw@redhat.com>,
	Jouni Malinen <jkm@devicescape.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from madara.hpl.hp.com ([192.6.19.124]:61402 "EHLO madara.hpl.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965331AbXCFRPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 12:15:32 -0500
Content-Disposition: inline
In-Reply-To: <1173144447.15891.93.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 02:27:26AM +0100, Johannes Berg wrote:
> Hi,
> 
> Wtf! After struggling with some strange problems with zd1211rw (see some
> other mail) I decided to think again about what could possibly cause all
> the other problems I'm having with it. The kernel seems fine, but iw*
> userspace continually segfaults! And it also seems to be not
> reproducible for most other people, I'd asked on IRC once a while.
> 
> Well. Some thinking and stracing and thinking later it occurred to me...
> Hell! wext is ioctls and includes this gem:
> 
> struct  iw_point
> {
>   void __user   *pointer;       /* Pointer to the data  (in user space) */
>   __u16         length;         /* number of fields or size in bytes */
>   __u16         flags;          /* Optional params */
> };
> 
> Of course nobody ever tells you this, but it's used in a shitload of
> places.

	Yep, and it's even in fs/compat_ioctl.c. Hint, hint ;-)

> Btw, did I mention that I'm running a stock debian powerpc 32-bit
> userspace on my 64-bit machine. Oh and of course wext doesn't have any
> 32-in-64 compat code.

	Please check again, it does.

> /me laughes manically about wext.
> 
> And don't tell me the fix is to use the netlink interface to wext.
> Actually, I think it may have the same bug, it seems to be operating
> with iw_point (or at least its size) too but I can't really tell, the
> code's just too clear, I always just see right through it... Oh and I
> still insist on removing the whole pile of junk, netlink interface
> first.

	Well, why don't you go and check it. For example, check
where IW_EV_POINT_OFF is used.

> Isn't there any possibility that we can kill userspace interfaces that
> are terminally broken without keeping them for years to come?

	Well, is there a possibility that people check the facts
before making bold assumptions ?

> Sorry. This is just too frustrating.

	Yes, you are perfectly right. This continuous bashing of wext
for no good reason is too frustrating.

> johannes

	Now, back to the problem. You seem to have an intermitent
crash. If the stuff above was broken, it would systematically crash,
because it would always get stuff at an offset.
	The fact that the crash is not systematic leads me to believe
that something else is at play, such as a compiler optimisation gone
bad, some memory condition, or a driver returning corrupted data to
wext and iwconfig not checking bad data properly.
	If you were to give me a proper bug report, there is a chance
that we might make progress.

	Have fun...

	Jean



