From: Rob Janssen <rob.janssen76@gmail.com>
Subject: Re: arcnet: protocol is buggy messages in 3.0 kernel, not in 2.33 kernel
Date: Tue, 22 May 2012 15:01:22 +0200
Message-ID: <CAJDhSdf++-CA8=+NNDu0Ah-y2quYCjSSzgbSuy+pF5xG19xDmg@mail.gmail.com>
References: <CAJDhSdc5J1xzvxYhvru6kjqAbq1NAtvWQCu-tXbi4aE_NXGXrg@mail.gmail.com>
	<20120503232352.GA3850@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:61784 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab2EVNBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 09:01:22 -0400
Received: by gglu4 with SMTP id u4so5318152ggl.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 06:01:22 -0700 (PDT)
In-Reply-To: <20120503232352.GA3850@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 4, 2012 at 1:23 AM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Rob Janssen <rob.janssen76@gmail.com> :
> [...]
>> Does anyone have what causes this message in the 3.0 kernel and/or how
>> to fix this ?
>
> Wild guess: hard_header_len is sizeof(struct archdr). archdr embeds a huge
> ethhdr but the header build helper only accounts for ARC_HDR_SIZE +
> RFC1201_HDR_SIZE.
>
> --
> Ueimor

I solved the problem:
The socket was opened with the wrong protocol: ETH_P_ALL instead of
ETH_P_ARCNET.
This causes arcnet messages to be sent to all network devices.
I don't know why older kernel versions didn't complain..

Rob
