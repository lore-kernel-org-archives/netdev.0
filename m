From: Maz The Northener <mazziesaccount@gmail.com>
Subject: Purpose of NLM_F_MATCH
Date: Tue, 13 Dec 2011 13:32:11 +0200
Message-ID: <CANhJrGMtu-MJkZAKDcfdMSZ6-b15jJ_3xSYuYq24K6sFm=roYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:40906 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab1LMLcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 06:32:11 -0500
Received: by dajs34 with SMTP id s34so2636648daj.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 03:32:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi dee Ho!

I have always thought that

"NLM_F_MATCH    Return all entries matching criteria passed in
                         message content."

in  RFC 3549 means that for example with RTM_GETROUTE we should return
those routes which match the details passed in struct rtmsg (and maybe
rtattrs given in the request.)

For example RTM_GETROUTE with

struct rtmsg *rtm=NLMSG_DATA(nlh);
memset(rtm,0,sizeof(struct rtmsg);
rtm->rtm_table=254;

would return only table 254 routes, yet all routes in table 254.
(similarly we could set other fields/attributes, and expect only
matching routes to be returned).

However I just found discussion from last january which hints me that
this might not be how the flag is interpreted by others.
(http://patchwork.ozlabs.org/patch/79103/)


My point is that I was thinking of writing a patch for IPv6, which
would interpret GETROUTE request with NLM_F_MATCH but no NLM_F_ROOT to
mean we want only entries matching passed criteria. (similar to
example abowe) Currently all routes are returned. Thus for example
with "ip route list" command it is the userspace which filters the
matching entries. However I think current behaviour is against the
original idea represented in RFC ?

However, I do not pretend to understand all the aspects. So I guess
I'd better to ask before doing... What is the wanted behaviour in this
case? Would it break existing stuff (again)? I believe that most apps
use NLM_F_DUMP or plain NLM_F_ROOT if they just want to get *all*
entries. And if they use NLM_F_MATCH alone, then they should have been
prepared to get only matching entries, right? (As I mentioned, iproute
uses NLM_F_DUMP, and then does the filtering - but it would propably
work with NLM_F_MATCH too - filters just would not catch anything to
filter.

It would simplify netlink usage if plain NLM_F_MATCH flag indicates
that user only wants matching entries, and yet all matching entries.
At the same time it would give a meaning for this flag (which
currently does not really differ from NLM_F_DUMP or NLM_F_ROOT), and
in my ears the specification for this flag sounds like it had been
originally invented for this purpose.

--Matti
