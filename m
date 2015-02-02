From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v2 0/6] net: Add STT support.
Date: Mon, 2 Feb 2015 10:44:47 -0800
Message-ID: <CALnjE+qzpQiE=C0+vpOjmUHOEh-KZb1OLczV1XkrMCXyHkb9=w@mail.gmail.com>
References: <1422574156-1831-1-git-send-email-pshelar@nicira.com>
	<20150131.174037.1176748996497876060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog117.obsmtp.com ([74.125.149.242]:39132 "HELO
	na3sys009aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932629AbbBBSos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 13:44:48 -0500
Received: by mail-ie0-f177.google.com with SMTP id vy18so19537304iec.8
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 10:44:47 -0800 (PST)
In-Reply-To: <20150131.174037.1176748996497876060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2015 at 5:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Thu, 29 Jan 2015 15:29:16 -0800
>
>> Following patch series adds support for Stateless Transport
>> Tunneling protocol.
>> STT uses TCP segmentation offload available in most of NIC. On
>> packet xmit STT driver appends STT header along with TCP header
>> to the packet. For GSO packet GSO parameters are set according
>> to tunnel configuration and packet is handed over to networking
>> stack. This allows use of segmentation offload available in NICs
>
> I don't like this at all.
>
> Routers _absolutely_ depend upon the ability to make TCP flows back
> off by dropping packets in various ways (tail drop, RED random drops,
> etc.).  STT violates this completely.
>
> It's _NOT_ TCP, you can't put lipstick on a pig and pretend it's not a
> pig.  You need to use something that indicates it's flow properties,
> a datagram protocol.  Either via an existing one or by creating a new
> one.
>
> I know you want to do this mass TCP behavioral violation because of
> TSO.  But that's too bad.  The ends do not justify the means.
>
> I also don't buy the argument that "people can put arbitrary changes
> into their kernel to do stuff like that".
>
> They can't do it to the stack I'm willing to maintain, and that's what
> matters for %99 of systems out there.

ok, I will drop patch series.
