From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Thu, 25 Feb 2016 10:09:18 +0000
Message-ID: <14B20F89-508D-4E6A-B02E-66422DC31783@gmail.com>
References: <1456241265-5766-1-git-send-email-gilberto.bertin@gmail.com> <CALx6S36_ii9hOj_Jn+xKxjoZQfbb-TfdQysH-N+Zic-bMHnHPg@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37034 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759750AbcBYKJU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 05:09:20 -0500
Received: by mail-wm0-f50.google.com with SMTP id g62so20308358wme.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 02:09:20 -0800 (PST)
In-Reply-To: <CALx6S36_ii9hOj_Jn+xKxjoZQfbb-TfdQysH-N+Zic-bMHnHPg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 24 Feb 2016, at 05:06, Tom Herbert <tom@herbertland.com> wrote:
>=20
> On Tue, Feb 23, 2016 at 7:27 AM, Gilberto Bertin
> <gilberto.bertin@gmail.com> wrote:
>> This series introduces support for the SO_BINDTOSUBNET socket option=
, which
>> allows a listener socket to bind to a subnet instead of * or a singl=
e address.
>>=20
>> Motivation:
>> consider a set of servers, each one with thousands and thousands of =
IP
>> addresses. Since assigning /32 or /128 IP individual addresses would=
 be
>> inefficient, one solution can be assigning subnets using local route=
s
>> (with 'ip route add local').
>>=20
> Hi Gilberto,
>=20
> The concept is certainly relevant, but allowing binds by subnet seems
> arbitrary. I can imagine that someone might want to bind to a list of
> addresses, list of interfaces, list of subnets, or complex
> combinations like a subnet on one interface, and list of addresses on
> another. So I wonder if this is another use case for a BPF program on
> a listener socket, like a program for a scoring function. Maybe this
> could even combined with  BPF SO_REUSERPORT somehow?
>=20
> Tom

Hi Tom,

thanks for commenting on my patch.
Your proposal is certainly more generic, but at the same time it would =
require
a bit more work to be used (at least for my specific case).
Indeed in my case it would be only a matter of calling setsockopt() wit=
h a
struct that decsribes the subnet, while with BPF it would be necessary =
to write
and load a scoring function (but at least the subnet descriptor can be =
stored
in a map, so there's no need to rewrite the filter for each different s=
ubnet).
Anyway, I=E2=80=99m curious to explore your idea.

Thanks,
  gilberto
