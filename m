From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] tcp: Add TCP_FREEZE socket option
Date: Wed, 22 Oct 2014 21:50:14 +0200
Message-ID: <CAPh34mechU=aUS422OBFhHUt68Nk2PZBsMiLPw8eLwS_4PnRtw@mail.gmail.com>
References: <1413992196-4891-1-git-send-email-kristian.evensen@gmail.com>
	<20141022.121418.1477947755244353588.davem@davemloft.net>
	<CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Kristian Evensen <kristian.evensen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:35685 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932640AbaJVTuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 15:50:16 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so3478664lbi.37
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 12:50:15 -0700 (PDT)
In-Reply-To: <CAKfDRXgARYe3hw3vgpgup1X4bNjH0cpwYOfKUZK51HcOf2jeJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 October 2014 19:08, Kristian Evensen <kristian.evensen@gmail.com> wrote:

> Another approach I designed was to have a separate TCP Freeze module
> and trigger the freeze/unfreeze through genetlink-messages. A user
> space application will be responsible for monitoring the devices and
> decide when to trigger the ZWAs. Would a design like that be
> acceptable?

At least better. But what userspace daemon would configure this?
Likely NetworkManager and friends. But at what conditions?

- When the WIFI signal strength is below some threshold?
- When switched to another AP?
- When switched from 802.11 to 802.3
- ...

In a NATed scenario there is no gain because IP addreses change and
the connection is lost anyway. For the signal strength thing there
might be an advantage but it has costs:

a) how long did you freeze the connection? What if NetworkManager
stops? The connection hang \infty
b) is it not better to inform the upper layer - the application - that
something happen with the link?

I mean when the application experience disruptions, the application
can decide what it do: reconnect, reconnect and resend or inform the
user. This possibility is now lost/hidden. Maybe it is no problem -
maybe it is for some applications.

I have no fundamental problems with TCP Freeze, but what is missing is
a complete story line. The use cases where it makes sense and if it is
save.

Do you have considered to bring this to the IETF (TCPM WG)?

Hagen
