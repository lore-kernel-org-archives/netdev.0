From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] scm: Don't use struct ucred in NETLINK_CB and struct scm_cookie.
Date: Fri, 07 Sep 2012 14:25:09 -0700
Message-ID: <87627ple4q.fsf@xmission.com>
References: <87haralb0u.fsf@xmission.com>
	<1347030446.2484.771.camel@edumazet-glaptop>
	<20120907.144151.1366430170552241987.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, serge@hallyn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52443 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab2IGVZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 17:25:21 -0400
In-Reply-To: <20120907.144151.1366430170552241987.davem@davemloft.net> (David
	Miller's message of "Fri, 07 Sep 2012 14:41:51 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 07 Sep 2012 17:07:26 +0200
>
>> Seems fine to me, but I am not sure why you kept NETLINK_CREDS()
>> defined/used once.
>
> There are two remaining users, kernel/audit.c and scsi netlink.

Good point.  I have a change to kernel/audit.c that removes the
usage.    I believe the scsi netlink usage is just plain bogus,
and it wants the netlink port identifier instead.

Would anyone mind if we changed the name of the field in netlink from
pid to portid?  It seems to cause a lot of confusion.  We can't change
the user space fields of course but...

Right now because we can now use current using NETLINK_CREDS in the
kernel is unnecessary.

Eric
