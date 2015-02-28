From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 16:56:16 -0800
Message-ID: <CAM_iQpUBp9bZGWTjq5UhFz4Z0Zt3YF-6cwkZafd54WP9cP8H+w@mail.gmail.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	<1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F09A95.8000507@6wind.com>
	<CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
	<54F0AE0B.5080101@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:38538 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbbB1A4Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 19:56:16 -0500
Received: by pdbfp1 with SMTP id fp1so24792480pdb.5
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 16:56:16 -0800 (PST)
In-Reply-To: <54F0AE0B.5080101@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 9:48 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 27/02/2015 18:28, Cong Wang a =C3=A9crit :
>> Then call it in do_setlink(). This is not a reason we _have to_
>> allocate it in dumping.
>
> Sure, but that just shows the 'over engineering' side ;-)
> The reason to allocate it in dumping is that you need it in dumping, =
not
> before ;-)

Why? This relies on rtnetlink to dump the link after creation,
which is not obvious at all. IOW, imagine if rtnetlink didn't do
the dump after new link, what would happen?

You are hiding it too deep, without a valid reason. It sounds
like you want to defer the allocation as late as possible,
but again it makes no sense: 1) we don't allocate too much,
just one id in idr; 2) this loses the code readability and hides
potential bugs.

You are over engineering, not me who wants to make it sane.
