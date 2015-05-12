From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v3] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Tue, 12 May 2015 18:10:56 +0200
Message-ID: <55522610.6090907@6wind.com>
References: <555216DA.3020105@6wind.com> <1431443865-4327-1-git-send-email-nicolas.dichtel@6wind.com> <20150512155842.GA2081@nanopsycho>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35502 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933325AbbELQLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 12:11:01 -0400
Received: by widdi4 with SMTP id di4so161062185wid.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 09:10:59 -0700 (PDT)
In-Reply-To: <20150512155842.GA2081@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/05/2015 17:58, Jiri Pirko a =E9crit :
> Tue, May 12, 2015 at 05:17:45PM CEST, nicolas.dichtel@6wind.com wrote=
:
[snip]
>> First, nobody seems to care about NETDEV_CHANGEINFODATA (commit
>> d4261e565000 says that it was put only to notify userspace). Hence, =
we can
>> call directly rtmsg_ifinfo().
>
> Please leave this notifier here. Will be needed in very near future f=
or
> LAG offloading purposes.
Ok.

>
>> Secondly, prevent in rtmsg_ifinfo() to send notifications to userspa=
ce
>> about unregistered interfaces.
>
> I'm not sure about this. Why caller of rtmsg_ifinfo don't take care o=
f
> it? Seems more logical to me.
Simply to avoid code duplication and ensure the bug will not show up in=
 the
future. The existing bug shows that it's easy to forget that check.
