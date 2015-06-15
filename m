From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Questions about 'ip link set DEV_NAME name DEV_NEWNAME'
Date: Mon, 15 Jun 2015 08:52:44 -0700
Message-ID: <20150615085244.120cd5e2@urahara>
References: <006101d0a76e$c2e800d0$48b80270$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?UTF-8?B?55Sz5pmT5qyi?= <sxhlinux@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34698 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723AbbFOPwm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 11:52:42 -0400
Received: by pacgb13 with SMTP id gb13so37916221pac.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 08:52:41 -0700 (PDT)
In-Reply-To: <006101d0a76e$c2e800d0$48b80270$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Jun 2015 21:25:30 +0800
=E7=94=B3=E6=99=93=E6=AC=A2 <sxhlinux@163.com> wrote:

> I'm using command 'ip link set ge0/0 name ge5/1' to rename interface =
name
> from ge0/0 to ge5/0. when command complete, command 'ifconfig' and 'c=
at
> /proc/net/dev ' both can output information of ge5/0,however command =
'ls
> /sys/class/net/' output "ls: /sys/class/net/ge5/0: No such file or
> directory".
>      There is no udev in my device, until to now command 'ip link' is=
 the
> only way to change interface name.=20
>      Anyone know solution to my problem, please give me some advice, =
thanks!
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Slashes are not allowed in network names on Linux because slash is
used as a file separator in sysfs. In normal Linux any attempt to
create or rename an interface to something with slash in it is rejected
with "Invalid argument"

I suspect you are using some vendor modified kernel (Juniper or Cisco?)=
 which
allows slash in filenames because how else would you get ge0/0.
If so, contact them it is there problem.
