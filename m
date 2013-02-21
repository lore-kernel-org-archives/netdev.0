From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why is it not allowed to add a new socket protocol family as an
 external module?
Date: Thu, 21 Feb 2013 08:43:08 -0800
Message-ID: <1361464988.17413.6.camel@edumazet-glaptop>
References: <5125002D.9080008@genband.com>
		 <20130220152325.64c57d55@samsung-9> <51256E02.4080509@genband.com>
	 <1361410797.17413.3.camel@edumazet-glaptop> <51264195.9060800@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:57645 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab3BUQnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 11:43:13 -0500
Received: by mail-pa0-f52.google.com with SMTP id fb1so4867921pad.39
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 08:43:11 -0800 (PST)
In-Reply-To: <51264195.9060800@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-21 at 09:47 -0600, Chris Friesen wrote:
> On 02/20/2013 07:39 PM, Eric Dumazet wrote:
> > On Wed, 2013-02-20 at 18:44 -0600, Chris Friesen wrote:
> >
> >> Yes, there are a number of tables sized by NPROTO/AF_MAX/PF_MAX (and the
> >> fact that we use all three within the kernel is kind of sad) but there
> >> is no technical reason why we couldn't extend those dynamically if
> >> desired (with a linked list of additional protocols, perhaps).
> >>
> >> Hence my question--is the restriction for an ideological reason or
> >> simply because nobody thought it was worth the effort?
> >>
> >
> > I guess nobody did the preliminary work.
> >
> > lockdep might be the tricky part.
> >
> > net/core/sock.c:197:static const char *const af_family_key_strings[AF_MAX+1] = {
> > net/core/sock.c:211:  "sk_lock-AF_NFC"   , "sk_lock-AF_MAX"
> > net/core/sock.c:213:static const char *const af_family_slock_key_strings[AF_MAX+1] = {
> > net/core/sock.c:227:  "slock-AF_NFC"   , "slock-AF_MAX"
> > net/core/sock.c:229:static const char *const af_family_clock_key_strings[AF_MAX+1] = {
> > net/core/sock.c:243:  "clock-AF_NFC"   , "clock-AF_MAX"
> > net/core/sock.c:250:static struct lock_class_key af_callback_keys[AF_MAX];
> 
> Unless I'm missing something that looks straightforward.
> 
> When registering dynamically the new protocol would need to specify one 
> string, the protocol name.  ("AF_MYPROTOCOL" or something).  The three 
> key strings are derived from that.
> 
> The three lock_class_key structs (corresponding to 
> af_family_keys/af_family_slock_keys/af_callback_keys) can be 
> auto-allocated by the network core at dynamic registration time.

Nope, this was the point I specifically raised but you missed it

Take a look at kernel/lockdep.c, lines 2981-2988

All the other stuff you mention seems pretty obvious.
