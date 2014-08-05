From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Fw: [Bug 81661] New: Network Performance Regression for large TCP
 transfers starting with v3.10
Date: Tue, 5 Aug 2014 11:43:01 -0400
Message-ID: <CADVnQym=zutyx=WDtaTnGQ=chKNcf553P5sry+FXDoyQQRykww@mail.gmail.com>
References: <20140804090529.1a5d146d@haswell.linuxnetplumber.net>
	<CADVnQy=mp+m3s1xp7cZ0r4gpwHbMAnBNxAxcQx-AUtB7dZieiQ@mail.gmail.com>
	<CADVnQynpqRkkY8eYrDZkkHUwyRgQsahyqVoU=T89ggG4xZi-Ww@mail.gmail.com>
	<E23079EBE6B5834E93E29FB5CC9C14930FD8DC0D@MUCSE502.eu.infineon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Yuchung Cheng <ycheng@google.com>
To: Alexander.Steffen@infineon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:41454 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755262AbaHEPnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 11:43:05 -0400
Received: by mail-wi0-f175.google.com with SMTP id ho1so7264108wib.2
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 08:43:01 -0700 (PDT)
In-Reply-To: <E23079EBE6B5834E93E29FB5CC9C14930FD8DC0D@MUCSE502.eu.infineon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 5, 2014 at 10:52 AM,  <Alexander.Steffen@infineon.com> wrote:
>> The  capture-bad-site1 trace seems to be a sender-side trace that
>> shows SACK blocks with sequence numbers that are 613M bytes ahead of
>> what has actually been sent, suggesting perhaps a middlebox is
>> rewriting sequence numbers, but not SACK options, or vice versa.
>
> It seems plausible that the network equipment somewhere tampers with
> the data passing through. I've asked our network experts to check the
> configuration again, specifically with regard to this suggestion.

Great. Thanks!

>> Would you be able to reproduce the capture-bad-site2 case but take a
>> sender-side tcpdump trace?
>
> capture-bad-site1 and capture-bad-site2 are already traces for the same events,
> taken simultaneously at the sending (site1) and the receiving (site2) end.
> Or is this not what you meant?

OK, great. Yes, that's what I meant, but I didn't realize that those
two traces were
of the same event. In that case, it definitely seems like the problem
is that some
middlebox rewrote the receiver's SACK values, invalidating them, so the sender
was unable to recover except via a retransmission timeout to repair each hole.

neal
