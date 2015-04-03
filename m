From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/4] netns: don't clear nsid too early on removal
Date: Fri, 03 Apr 2015 11:56:09 +0200
Message-ID: <551E63B9.9050208@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>	<1427892589-4266-2-git-send-email-nicolas.dichtel@6wind.com> <877ftus6rj.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:36705 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbbDCJ4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 05:56:12 -0400
Received: by wgra20 with SMTP id a20so107194830wgr.3
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 02:56:11 -0700 (PDT)
In-Reply-To: <877ftus6rj.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/04/2015 20:51, Eric W. Biederman a =C3=A9crit :
[snip]
>
> There should be no network sockets and thus no in flight rtnl traffic=
 at
> the time cleanup_net is metioned so I don't see how this patch fixes
> the mentioned commit.
Yes and no.
Yes, there is no network sockets into this netns, *but* modules build
netlink messages because they don't know if there are listeners or not.

>
> I have a second issue with the fact that the code is unnecessarily
> quadratic.  We should keep a list of the issues netns ids and just
> revoke them instead of walking the whole network namespaces.
>
> I strongly suspect that this change makes it possible to create a
> network device whose bottom is in a network namespace we are destroyi=
ng
> after we have destroyed all of the network devices in that namespace =
and
> otherwise cleaned up.   Beyond that I can not reason about this patch
> because it opens up a huge number of races.
Ok, you're probably right.
I will send an update.
