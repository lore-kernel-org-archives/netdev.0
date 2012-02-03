From: Xiaochun Lu <xiaoclu@gmail.com>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 2 Feb 2012 18:15:58 -0800
Message-ID: <CAOdseAMSv-V3S0rGMj+Kq0EUtF_44zKNxZW-mOMyGT_Bp8Hfyw@mail.gmail.com>
References: <1328218567-3134-1-git-send-email-ehoover@mines.edu>
	<1328219828.2480.32.camel@edumazet-laptop>
	<CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	<CAOdseAOsGOD2bxOwQLZPq6KhL5xN9J81=d1tQWEULDZwxD9UxA@mail.gmail.com>
	<CAEU2+voODFayVZ1=VGfhQk_VQzyHH+8Nj6M1GKrHq47gOPnuMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev <netdev@vger.kernel.org>,
	"shawn.lu" <shawn.lu@ericssion.com>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62890 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719Ab2BCCP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 21:15:58 -0500
Received: by yenm8 with SMTP id m8so1421916yen.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 18:15:58 -0800 (PST)
In-Reply-To: <CAEU2+voODFayVZ1=VGfhQk_VQzyHH+8Nj6M1GKrHq47gOPnuMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for explanation.  The log is good to me

On 2/2/12, Erich E. Hoover <ehoover@mines.edu> wrote:
> On Thu, Feb 2, 2012 at 6:19 PM, Xiaochun Lu <xiaoclu@gmail.com> wrote:
>> Hi, Erich E. Hoover:
>>
>> Can you give more detail on why we need invent another binding to
>> device option in your patch log?  Why SO_BINDTODEVICE or IP_PKTINFO
>> can't server your need?
>
> Sure, how about adding something like the following?:
> ---
> The IP_UNICAST_IF feature is needed by the Wine project.  This patch
> implements the feature by setting the outgoing interface in a similar
> fashion to that of IP_PKTINFO.  A separate option is needed to handle
> this feature since the existing options do not provide all of the
> characteristics required by IP_UNICAST_IF, a summary is provided
> below.
>
> SO_BINDTODEVICE:
> * SO_BINDTODEVICE requires administrative privileges, IP_UNICAST_IF
> does not.  From reading some old mailing list articles my
> understanding is that SO_BINDTODEVICE requires administrative
> privileges because it can override the administrator's routing
> settings.
> * The SO_BINDTODEVICE option restricts both outbound and inbound
> traffic, IP_UNICAST_IF only impacts outbound traffic.
>
> IP_PKTINFO:
> * Since IP_PKTINFO and IP_UNICAST_IF are independent options,
> implementing IP_UNICAST_IF with IP_PKTINFO will likely break some
> applications.
> * Implementing IP_UNICAST_IF on top of IP_PKTINFO significantly
> complicates the Wine codebase and reduces the socket performance
> (doing this requires a lot of extra communication between the "server"
> and "user" layers).
>
> bind():
> * bind() does not work on broadcast packets, IP_UNICAST_IF is
> specifically intended to work with broadcast packets.
> ---
>
> Erich Hoover
> ehoover@mines.edu
>
