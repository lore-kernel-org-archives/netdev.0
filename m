From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 10:11:00 -0700
Message-ID: <AANLkTik7WxP0RBBqw1jrs9eJewtR4+5smyyZGG0zWNSn@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
 <20101025213841.635b9a15@nehalam> <AANLkTinGpt=EQX3aXRaj5mEUMDNpyEapbs4VyOwgtN55@mail.gmail.com>
 <20101026082832.4c5af2ef@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:6177 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab0JZRL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:11:28 -0400
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o9QHBRpX013666
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:11:27 -0700
Received: from gya6 (gya6.prod.google.com [10.243.49.6])
	by kpbe20.cbf.corp.google.com with ESMTP id o9QHBBDx002600
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:11:25 -0700
Received: by gya6 with SMTP id 6so3448721gya.18
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 10:11:25 -0700 (PDT)
In-Reply-To: <20101026082832.4c5af2ef@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 8:28 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
>> That won't help the case I am trying to fix, which is the case where
>> the new link has a global prefix different than the old link. Marking
>> the addresses as tentative will simply make them pass DAD and come
>> back as soon as link comes back. But since they don't match the prefix
>> that is assigned to the new link, they are unusable, because packets
>> can't be routed back to them.
>
> For IPv4 this is already handled by network manager.
> Why couldn't the same apply to IPv6?

I think addresses should be deleted by the entity that configured
them. In IPv4, the addresses are created by userspace daemons like
networkmanager or DHCP, and so they should be deleted by
networkmanager as well. In IPv6, autoconf addresses are created by the
kernel, and so should be deleted by the kernel.

Otherwise, userspace daemons that are not IPv6 aware must listen to
see what addresses are created, deleting them if they think they need
to go away, and possibly even racing with the kernel (e.g., imagine
networkmanager purging IPv6 addresses just before the kernel processes
an RA that adds new IPv6 addresses).

>> What's the additional failure scenario? Will it help if I make it so
>> that link-local addresses aren't touched at all?
>
> Link-local works fine.

Ok, so if global addresses work, then the patch doesn't need to do
anything special with link-local?
