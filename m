From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not used
Date: Tue, 14 Dec 2010 13:46:39 -0800
Message-ID: <AANLkTiktJXEyofbaoOvSJEtqk5bL5VbzP7fbbFHZkru+@mail.gmail.com>
References: <1291536233.2806.102.camel@edumazet-laptop>
	<20101205105528.49fa9a9f@xenia.leun.net>
	<20101205114404.7c0cddc2@xenia.leun.net>
	<AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	<20101206203437.54b550e0@xenia.leun.net>
	<AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	<20101206222703.32fbe852@xenia.leun.net>
	<AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	<20101213224510.GB17400@mcarlson.broadcom.com>
	<AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	<20101214191500.GD19951@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214191500.GD19951@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2010 at 11:15 AM, Matt Carlson <mcarlson@broadcom.com> =
wrote:
> @@ -9538,17 +9505,8 @@ static void __tg3_set_rx_mode(struct net_devic=
e *dev)
> =A0 =A0 =A0 =A0/* When ASF is in use, we always keep the RX_MODE_KEEP=
_VLAN_TAG
> =A0 =A0 =A0 =A0 * flag clear.
> =A0 =A0 =A0 =A0 */
> -#if TG3_VLAN_TAG_USED
> - =A0 =A0 =A0 if (!tp->vlgrp &&
> - =A0 =A0 =A0 =A0 =A0 !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_mode |=3D RX_MODE_KEEP_VLAN_TAG;
> -#else
> - =A0 =A0 =A0 /* By definition, VLAN is disabled always in this
> - =A0 =A0 =A0 =A0* case.
> - =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_mode |=3D RX_MODE_KEEP_VLAN_TAG;
> -#endif

Just one comment:

I don't think this does quite the right thing: it will always disable
vlan stripping unless ASF is in use.  However, it's now OK to always
use vlan stripping, so we might as well take advantage of it.  Since
without the set_flags Ethtool op there is no way to change this
setting, we should be able to just drop this code block completely
(and the check for  RX_MODE_KEEP_VLAN_TAG on receive).

In addition, this should also remove any differences between ASF
enabled/disabled firmware (at least with respect to vlans) since it
will no longer be a factor.

Thanks.
