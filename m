From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next V2] bond: have random dev address by default instead of zeroes
Date: Fri, 25 Jan 2013 10:31:32 -0800
Message-ID: <22106.1359138692@death.nxdomain>
References: <542237717.4200599.1359136587903.JavaMail.root@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, dcbw@redhat.com,
	Jiri Pirko <jiri@resnulli.us>
To: Pavel Simerda <psimerda@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:36386 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806Ab3AYSbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 13:31:42 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 25 Jan 2013 11:31:42 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 984DC3E40040
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 11:31:32 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PIVckP026676
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 11:31:38 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PIVY4l013589
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 11:31:35 -0700
In-reply-to: <542237717.4200599.1359136587903.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Simerda <psimerda@redhat.com> wrote:

>----- Original Message -----
>> From: "Jay Vosburgh" <fubar@us.ibm.com>
>> but I don't think it should be changed.
>
>Just a short question. Is there any reason for bonding interfaces to
>behave differently from bridging interfaces in this respect?

	To clarify, what I don't think should change is that a manually
set MAC on the bonding master should override the automatic copy of the
first slave's MAC to the bonding master.  The fail_over_mac active and
follow settings are an exception to this, but those are special cases
for unusual network hardware.

	As for the random MAC vs. zero MAC, I've always thought that the
all zero MAC was a clear indicator that the device (the bonding master
in this case) was not in a usable state (in the sense that it could not
send or receive actual traffic).  It's not a really big deal, though, so
if the trend these days is for everything to have a MAC all the time,
that's fine, as long as doing so doesn't break anything.

	I think the patch under discussion should be fine with the
addition of the last notifier call previously discussed.  Some
documentation updates would be nice, too.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
