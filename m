From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Tue, 26 Mar 2013 08:31:00 -0700
Message-ID: <1364311860.1716.31.camel@edumazet-glaptop>
References: <CD773D0D.7614%blourdel@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Serge Hallyn <serge.hallyn@ubuntu.com>
To: Benoit Lourdelet <blourdel@juniper.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:41533 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933334Ab3CZPbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 11:31:10 -0400
Received: by mail-pa0-f46.google.com with SMTP id wp1so1667550pac.33
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 08:31:07 -0700 (PDT)
In-Reply-To: <CD773D0D.7614%blourdel@juniper.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-03-26 at 11:51 +0000, Benoit Lourdelet wrote:

> The script to delete:
> for d in /sys/class/net/veth*; do
> 	ip link del `basename $d` 2>/dev/null || true
> Done
> 
> There is a very good improvement in deletion.

I can do better ;)

If you are really doing this kind of things, you could use :

rmmod veth

Note that "ip" command supports a batch mode

ip -batch filename

In this case, the caching is done only once.

Eric, Stephen, one possibility would be to use the cache only in batch
mode.

Anyway caching is wrong because several users can use ip command at the
same time.
