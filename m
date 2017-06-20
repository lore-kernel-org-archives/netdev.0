From: =?UTF-8?Q?Lars_Erik_Storbuk=C3=A5s?= <larserik.storbukas@gmail.com>
Subject: Re: TCP Vegas per-socket alpha, beta, gamma parameters
Date: Tue, 20 Jun 2017 10:54:37 +0100
Message-ID: <CA+yK=LvkLA+LV8K-oeEMKF9PdbwA-bnWi+6oOPstvtWxrGt4-Q@mail.gmail.com>
References: <CAF0XkCCmL4nxQbvGOVneRqh_9bofc+yFe=nrJAQzGv+nHmEWvg@mail.gmail.com>
 <AD8C2BD7-0633-4927-8155-D4297D7B71C1@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@vger.kernel.org>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34986 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdFTJyn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 05:54:43 -0400
Received: by mail-pg0-f45.google.com with SMTP id 132so26800141pgb.2
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 02:54:43 -0700 (PDT)
In-Reply-To: <AD8C2BD7-0633-4927-8155-D4297D7B71C1@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 19, 2017 at 3:30 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
> Hi Lars,
>
> You would need to modify the source code to support per connection alpha,=
 beta and gamma parameters. Although you can modify the parameters at runti=
me, they would apply to all connections using Vegas, both existing and new =
ones.
>
> You may also want to consider using TCP NV (New Vegas) instead. It works =
better in current networks and servers.
>
> - Lawrence Brakmo
>
>
> On 6/19/17, 6:48 AM, "netdev-owner@vger.kernel.org on behalf of Lars Erik=
 Storbuk=C3=A5s" <netdev-owner@vger.kernel.org on behalf of storbukas.dev@g=
mail.com> wrote:
>
>     I'm looking into how I can modify alpha, beta and gamma parameters fo=
r
>     TCP Vegas on a per-socket basis (if at all possible). I want to modif=
y
>     the sending rate per-socket dynamically  (not system wide) when a
>     delay-based algorithm is used.
>
>     Is it possible to modify the parameters of Vegas without modifying th=
e
>     source code of Vegas itself?
>
>     Would setting the (system wide) alpha, beta and gamma parameters be
>     updated immediately? Would an ongoing transmission get the new values
>     of alpha, beta or gamma when they are modified, or is it read only
>     when initialising a Vegas transmission?
>
>     Background for question:
>     I'm working on the implementation of a Deadline Aware, Less than Best
>     Effort. A framework for adding both LBE behaviour and awareness of
>     =E2=80=9Csoft=E2=80=9D delivery deadlines to any congestion control (=
CC) algorithm,
>     whether loss-based, delay- based or explicit signaling-based. This
>     effectively allows it to turn an arbitrary CC protocol into a
>     scavenger protocol that dynamically adapts its sending rate to networ=
k
>     conditions and remaining time before the deadline, to balance
>     timeliness and transmission aggressiveness.
>
>     / Lars Erik Storbuk=C3=A5s (storbukas.dev@gmail.com)
>
>

Thanks for a quick response!

I definetively see New Vegas as working better in current networks and
servers. I do however, need to support Vegas when implementing this.

Do you have any input of the best practice on how to provide (an
optional) per-socket configuration for alpha, beta and gamma
parameters? In other words when modifying the existing Vegas code.

Maybe it's possible to do add a parameters struct like this:

struct vegas {
u8 enabled;
u32 alpha;
u32 beta;
u32 gamma;
}

If vegas.enabled is set, it could use the per-socket parameters, and
if not, then it will use the system wide settings. Does this seem
logical?

Any help is greatly appreciated.

/ Lars Erik Storbuk=C3=A5s (storbukas.dev@gmail.com)
