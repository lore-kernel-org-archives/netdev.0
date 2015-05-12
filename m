From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net v3] rtnl/bond: don't send rtnl msg for unregistered
 iface
Date: Tue, 12 May 2015 18:14:02 +0200
Message-ID: <20150512161402.GC2081@nanopsycho>
References: <555216DA.3020105@6wind.com>
 <1431443865-4327-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150512155842.GA2081@nanopsycho>
 <55522610.6090907@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37303 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194AbbELQOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 12:14:08 -0400
Received: by widdi4 with SMTP id di4so22428540wid.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 09:14:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55522610.6090907@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 12, 2015 at 06:10:56PM CEST, nicolas.dichtel@6wind.com wrote:
>Le 12/05/2015 17:58, Jiri Pirko a =E9crit :
>>Tue, May 12, 2015 at 05:17:45PM CEST, nicolas.dichtel@6wind.com wrote=
:
>[snip]
>>>First, nobody seems to care about NETDEV_CHANGEINFODATA (commit
>>>d4261e565000 says that it was put only to notify userspace). Hence, =
we can
>>>call directly rtmsg_ifinfo().
>>
>>Please leave this notifier here. Will be needed in very near future f=
or
>>LAG offloading purposes.
>Ok.
>
>>
>>>Secondly, prevent in rtmsg_ifinfo() to send notifications to userspa=
ce
>>>about unregistered interfaces.
>>
>>I'm not sure about this. Why caller of rtmsg_ifinfo don't take care o=
f
>>it? Seems more logical to me.
>Simply to avoid code duplication and ensure the bug will not show up i=
n the
>future. The existing bug shows that it's easy to forget that check.

I don't know, seems to me more like curing consequence, not the cause.
