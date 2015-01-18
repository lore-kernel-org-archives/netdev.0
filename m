From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Bridge code in net-next does not compile
Date: Sun, 18 Jan 2015 11:39:38 +0100
Message-ID: <20150118103938.GA1944@nanopsycho.orion>
References: <D49DF51C-D713-4D2C-9CB0-F7C21403F68A@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:34086 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbbARKjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 05:39:41 -0500
Received: by mail-wg0-f53.google.com with SMTP id x13so27136573wgg.12
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 02:39:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <D49DF51C-D713-4D2C-9CB0-F7C21403F68A@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jan 18, 2015 at 11:33:24AM CET, marcel@holtmann.org wrote:
>Hi,
>
>when compiling net-next, the bridge code fails to compile:
>
>  CC      net/bridge/br.o
>In file included from net/bridge/br.c:22:0:
>include/net/switchdev.h:73:1: error: expected identifier or =E2=80=98(=
=E2=80=99 before =E2=80=98{=E2=80=99 token
> {
> ^
>include/net/switchdev.h:71:90: warning: =E2=80=98call_netdev_switch_no=
tifiers=E2=80=99 declared =E2=80=98static=E2=80=99 but never defined [-=
Wunused-function]
> static inline int call_netdev_switch_notifiers(unsigned long val, str=
uct net_device *dev,

Hi, I already sent fix:

http://patchwork.ozlabs.org/patch/430160/

>                                                                      =
                    ^
>
>I bisecting this to this commit:
>
>commit 03bf0c281234028388108d0aee720954f5fe6924
>Author: Jiri Pirko <jiri@resnulli.us>
>Date:   Thu Jan 15 23:49:36 2015 +0100
>
>    switchdev: introduce switchdev notifier
>   =20
>    This patch introduces new notifier for purposes of exposing events=
 which happen
>    on switch driver side. The consumers of the event messages are mai=
nly involved
>    masters, namely bridge and ovs.
>   =20
>    Suggested-by: Thomas Graf <tgraf@suug.ch>
>    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>    Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>    Signed-off-by: David S. Miller <davem@davemloft.net>
>
>Regards
>
>Marcel
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
