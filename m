From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] pktgen: Add NOINIT option to leave packet data
 uninitialized
Date: Fri, 16 May 2014 09:15:01 -0700
Message-ID: <1400256901.7973.200.camel@edumazet-glaptop2.roam.corp.google.com>
References: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch>
	 <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
	 <53761286.2040505@candelatech.com>
	 <1400250203.7973.173.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516145032.GD8346@casper.infradead.org>
	 <1400252935.7973.176.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516152035.GE8346@casper.infradead.org>
	 <1400253971.7973.186.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516153902.GG8346@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49401 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757071AbaEPQPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:15:06 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so2800224pbc.12
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 09:15:05 -0700 (PDT)
In-Reply-To: <20140516153902.GG8346@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 16:39 +0100, Thomas Graf wrote:

>  I don't see why the choice of deliberately exposing kernel memory
> in either of these cases is an issue.

This has been discussed a long time ago, when I had such claims, as root
user "should be able to get dirty pages". If I remember, this was a new
mmap() flag or something like that.

(Ie not requiring clear new pages)

This was of course rejected for upstream linux, for _very_ good reasons.

With the advent of network namespaces, you could have the right to use
pktgen on your ethernet device, without allowing you to read arbitrary
kernel memory.

The day its done, we would have to revert your change, and it is very
possible nobody catch this dependency.

Really this is simply about basic security concerns with an incredibly
complex code base.
