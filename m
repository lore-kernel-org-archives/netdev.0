From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] remove NLA_STRING NUL trimming
Date: Fri, 23 Mar 2007 15:20:46 +0100
Message-ID: <20070323142046.GC521@postel.suug.ch>
References: <1174605138.3588.54.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:60210 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753101AbXCWOU0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 10:20:26 -0400
Content-Disposition: inline
In-Reply-To: <1174605138.3588.54.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2007-03-23 00:12
> Looking through the netlink/attr.c code I noticed that NLA_STRING
> attributes that end with a binary NUL have it removed before passing it
> to the consumer.

It's not really removed, the trailing NUL is just ignored when checking
the length of the attribute. This is needed for older netlink families
where strings are not always NUL terminated, yet we still need to accept
the additional byte needed in case it is present. This validation is
strictly necessary, otherwise nla_strcmp() and others will fail.

> For wireless, we have a few places where we need to be able to accept
> any (even binary) values, for example for the SSID; the SSID can validly
> end with \0 and I'd still love to be able to take advantage of
> NLA_STRING and .len = 32 so I don't need to check the length myself.
> However, given the code above, an SSID with a terminating \0 would be
> reduced by one character.

I suggest that you introduce NLA_BINARY which enforces a maximum length.
