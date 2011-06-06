From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: 3.0.0-rc1: dmesg shows 'wlan%d' instead of 'wlan0'
Date: Mon, 6 Jun 2011 10:13:08 +0530
Message-ID: <BANLkTimLXr1+OLtGGXE2kzccRRG5T-G2mw@mail.gmail.com>
References: <20110605201042.21c86763@sf>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Trofimovich <slyich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110605201042.21c86763@sf>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 5, 2011 at 10:40 PM, Sergei Trofimovich <slyich@gmail.com> =
wrote:
> Recently I've noticed small discrepancy in dmesg:
>
> $ { zcat messages.2.gz messages.1.gz; cat messages; } | egrep "(deaut=
hen|Linux version)"
> ...
> May 21 22:01:31 sf kernel: [ =A0 =A00.000000] Linux version 2.6.39-00=
004-g29c77fa (slyfox@sf) (gcc version 4.4.5 (Gentoo 4.4.5 p1.2, pie-0.4=
=2E5) ) #116 SMP PREEMPT Thu May 19 22:46:16 EEST 2011
> May 24 05:37:54 sf kernel: [81845.885094] wlan0: deauthenticated from=
 ...
>
> Jun =A01 22:38:38 sf kernel: [ =A0 =A00.000000] Linux version 3.0.0-r=
c1-00035-g79f3f61 (slyfox@sf) (gcc version 4.4.5 (Gentoo 4.4.5 p1.2, pi=
e-0.4.5) ) #118 SMP PREEMPT Wed Jun 1 22:14:46 EEST 2011
> Jun =A01 23:41:23 sf kernel: [ 3877.773727] wlan%d: deauthenticating =
from ...
>
> Jun =A01 23:42:16 sf kernel: [ =A0 =A00.000000] Linux version 3.0.0-r=
c1-00035-g79f3f61-dirty (slyfox@sf) (gcc version 4.4.5 (Gentoo 4.4.5 p1=
=2E2, pie-0.4.5) ) #119 SMP PREEMPT Wed Jun 1 23:35:43 EEST 2011
> Jun =A02 07:35:10 sf kernel: [ 5972.879970] wlan%d: deauthenticated f=
rom ...
>
> Here we see 'wlan0' -> 'wlan%d' switch. I presume those lines go from=
 firmware
> (and not from userspace).
>
> The card is an iwl4965
>
> 10:00.0 Network controller: Intel Corporation PRO/Wireless 4965 AG or=
 AGN [Kedron] Network Connection (rev 61)


this seems to be fixed by the following commit which was recently
merged in wireless-testing

commit 59e7e7078d6c2c6294caf454c6e3695f9d3e46a2
Author: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Date:   Thu Jun 2 17:28:37 2011 -0300

    mac80211: call dev_alloc_name before copying name to sdata

    This partially reverts 1c5cae815d19ffe02bdfda1260949ef2b1806171, be=
cause
    the netdev name is copied into sdata->name, which is used for debug=
ging
    messages, for example. Otherwise, we get messages like this:

    wlan%d: authenticated

    Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.c=
om>
    Cc: Jiri Pirko <jpirko@redhat.com>
    Cc: David S. Miller <davem@davemloft.net>
    Cc: Johannes Berg <johannes@sipsolutions.net>
    Cc: "John W. Linville" <linville@tuxdriver.com>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>


are we still getting it?

>
> --
>
> =A0Sergei
>



--=20
shafi
