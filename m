From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Wed, 21 Oct 2009 05:16:54 -0400
Message-ID: <4ADED186.3040300@gmail.com>
References: <b2cc26e40910100601q7aed04acjcc9973ef06e6458f@mail.gmail.com>	 <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>	 <b2cc26e40910210017v3885b18dre5021c8a920f30d7@mail.gmail.com>	 <4ADEB752.50103@gmail.com> <b2cc26e40910210048y43bdb604pcd356376a93c41e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:46603 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbZJUJQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 05:16:54 -0400
Received: by ywh40 with SMTP id 40so4309957ywh.33
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 02:16:58 -0700 (PDT)
In-Reply-To: <b2cc26e40910210048y43bdb604pcd356376a93c41e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olaf van der Spek wrote:
> On Wed, Oct 21, 2009 at 9:25 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> This is a user selectable setting. What's wrong with /etc/sysctl.conf ?
> 
> It requires user action...
> Often you notice cookies are disabled only after a service becomes unreachable.
> What's wrong with improving defaults?

I've not been a regular contributor here, so I'm not sure that my view has
much weight, but I'm *against* changing the coded default.

Keep in mind that I'm busy trying to replace syncookies with real cookies,
so I'm biased.  The syncookies interfere with new options; although in
Linux, they interfere less than other systems.

For Ubuntu, the practice is complicated.  In /etc/sysctl.conf, the text
assumes that the default is off:

# Uncomment the next line to enable TCP/IP SYN cookies
# This disables TCP Window Scaling (http://lkml.org/lkml/2008/2/5/167),
# and is not recommended.
#net.ipv4.tcp_syncookies=1

But in the default installed /etc/sysctl.d/10-network-security.conf, it
is explicitly on in any case:

# Turn on SYN-flood protections.  Starting with 2.6.26, there is no loss
# of TCP functionality/features under normal conditions.  When flood
# protections kick in under high unanswered-SYN load, the system
# should remain more stable, with a trade off of some loss of TCP
# functionality/features (e.g. TCP Window scaling).
net.ipv4.tcp_syncookies=1

As Ubuntu is debian based, perhaps they can back-port the Ubuntu changes?


> Don't forget the missing log entries.
> 
On this I agree.  I'd like the system to syslog it's under attack,
especially whenever syncookies are off.
