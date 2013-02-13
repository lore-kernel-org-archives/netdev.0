From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp_use_frto crashes on empty tcp_write_queue
Date: Wed, 13 Feb 2013 15:24:10 -0800
Message-ID: <1360797850.6884.39.camel@edumazet-glaptop>
References: <511C0127.1040604@citrix.com>
	 <1360791453.6884.34.camel@edumazet-glaptop> <511C1039.9020001@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frediano Ziglio <frediano.ziglio@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f43.google.com ([209.85.210.43]:35185 "EHLO
	mail-da0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965338Ab3BMXYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 18:24:17 -0500
Received: by mail-da0-f43.google.com with SMTP id u36so770034dak.2
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2013 15:24:16 -0800 (PST)
In-Reply-To: <511C1039.9020001@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-13 at 22:14 +0000, Zoltan Kiss wrote:
> Hi,
> 
> On 13/02/13 21:37, Eric Dumazet wrote:
> > This doesn't seem to be a standard kernel.
> 
> Indeed, this is a XenServer 6.0.2 kernel, which contains changes, 
> however the TCP parts are barely modified. The related code path were 
> not changed.
> I'm trying to determine if this bug could be fixed in an obvious way, so 
> let me rephrase my question: if the socket write queue is empty, 
> shouldn't we just stop going further instead of dropping a WARN? Or, if 
> there is a reason to do so, shouldn't we check at least that returned 
> pointer in tcp_use_frto()?

You could change the WARN_ON() to BUG_ON(), as there is a severe bug in
your tree (and possibly in current trees as well, but its hard to say,
given 2.6.32 is probably missing some tcp fixes)

Trying to hide the bug wont really help.

How write_queue can be empty and packets_out not null ?
