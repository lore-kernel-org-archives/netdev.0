From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 01/14] gso: Remove arbitrary checks for
 unsupported GSO
Date: Thu, 5 May 2016 09:09:21 -0700
Message-ID: <CAKgT0Uc32UBGMAiPRhbGiQXrnqsfG7_6tdKLp7AuOT8W7qm39A@mail.gmail.com>
References: <1462410164-1953217-1-git-send-email-tom@herbertland.com>
	<1462410164-1953217-2-git-send-email-tom@herbertland.com>
	<CAKgT0UeZWv7pnHNC8b5zjPe=SxZBz9EBUGkxnnjnqkmhDe34xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:35313 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756808AbcEEQJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 12:09:22 -0400
Received: by mail-ig0-f181.google.com with SMTP id bi2so20145164igb.0
        for <netdev@vger.kernel.org>; Thu, 05 May 2016 09:09:22 -0700 (PDT)
In-Reply-To: <CAKgT0UeZWv7pnHNC8b5zjPe=SxZBz9EBUGkxnnjnqkmhDe34xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 7:59 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Wed, May 4, 2016 at 6:02 PM, Tom Herbert <tom@herbertland.com> wrote:
>> In several gso_segment functions there are checks of gso_type against
>> a seemingly abitrary list of SKB_GSO_* flags. This seems like an
>> attempt to identify unsupported GSO types, but since the stack is
>> the one that set these GSO types in the first place this seems
>> unnecessary to do. If a combination isn't valid in the first
>> place that stack should not allow setting it.
>
> You would think that was the case.  The problem is I have already seen
> one issue with GUE allowing an unsupported combination of GRE_CSUM and
> UDP tunnels.

I thought about this some more and it isn't as if the checks would
have caught this anyway as the GRE bits were being skipped over.  I'd
say we can probably just drop all these checks and save ourselves the
space.  So I retract my earlier comments against this specific patch
and will Ack it when we get the issues with the other patches in the
series resolved.

- Alex
