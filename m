From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Generic netlink interface help
Date: Sat, 26 May 2007 00:18:02 +0200
Message-ID: <20070525221802.GO521@postel.suug.ch>
References: <84po8XY4.1179999810.5490870.samuel@sortiz.org> <1180024477.18003.11.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Samuel Ortiz <samuel@sortiz.org>, giometti@enneenne.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50352 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146AbXEYWRm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 18:17:42 -0400
Content-Disposition: inline
In-Reply-To: <1180024477.18003.11.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2007-05-24 18:34
> On Thu, 2007-05-24 at 09:43 +0000, Samuel Ortiz wrote:
> 
> > You probably want to use the libnl library. The latest SVN code has
> > support for generic netlink:
> > http://people.suug.ch/~tgr/libnl/
> 
> Huh. I just looked at it and I don't understand anything. What's the
> point with genl_register/genl_unregister and having a table of commands
> etc? Thomas, can you explain how I should use libnl for nl80211 now? I
> mean, I can see what I can do with just sending/receiving messages but
> it feels like I'm missing something with all that other infrastructure
> in libnl.

This area is still work in progress but the basic idea is that
like in kernel context, the application defines its set of
commands and assigns message parsers for each command. For now,
the message parser is linked into the cache operations which
means that you have to "update" a cache in order to use this
feature. This is obviously not optimal so what I might end up
is to allow changing the "valid message" callback to be set to
a parser function which takes the list of operations and does
the demuxing.
