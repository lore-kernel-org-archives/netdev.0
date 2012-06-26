From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH 1/1] atl1c: fix issue of transmit queue 0 timed out
Date: Tue, 26 Jun 2012 13:54:36 -0700
Message-ID: <20120626205436.GJ5070@tux>
References: <1340724786-3819-1-git-send-email-cjren@qca.qualcomm.com>
 <20120626180311.GC5070@tux>
 <157393863283F442885425D2C454285623DB49B7@NASANEXD02A.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ren, Cloud" <cjren@qca.qualcomm.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C454285623DB49B7@NASANEXD02A.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 26, 2012 at 01:41:11PM -0700, Huang, Xiong wrote:
> Luis
>    It should be a stable fix, but as Ben Hutchings mentioned in anoth=
er mail,=20
> Maybe, removing netif_stop_queue when cable link down is a better cho=
ice.
>=20
>    Do you mean we need add 'cc:stable@vger.kernel.org'  just before '=
some people report  ...' ?

Nope, see commit 4f7a67e2dd49fbfba002c453bc24bf00e701cc71
as an example of how to do this. This is a random commit
that has been marked as stable.

commit 4f7a67e2dd49fbfba002c453bc24bf00e701cc71
Author: Ricardo Martins <rasm@fe.up.pt>
Date:   Tue May 22 18:02:03 2012 +0100

    USB: fix PS3 EHCI systems
   =20
    After commit aaa0ef289afe9186f81e2340114ea413eef0492a "PS3 EHCI QH
    read work-around", Terratec Grabby (em28xx) stopped working with AM=
D
    Geode LX 800 (USB controller AMD CS5536). Since this is a PS3 only
    fix, the following patch adds a conditional block around it.
   =20
    Signed-off-by: Ricardo Martins <rasm@fe.up.pt>
    Acked-by: Alan Stern <stern@rowland.harvard.edu>
    Cc: stable <stable@vger.kernel.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Sometimes it helps if you specify the oldest stable kernel
to apply patches to, so for example:

commit 80b08a8d8829a58b5db14b1417151094cc28face
Author: Felix Fietkau <nbd@openwrt.org>
Date:   Fri Jun 15 03:04:53 2012 +0200

    ath9k: fix invalid pointer access in the tx path
   =20
    After setup_frame_info has been called, only info->control.rates is=
 still
    valid, other control fields have been overwritten by the ath_frame_=
info
    data. Move the access to info->control.vif for checking short pream=
ble
    to setup_frame_info before it gets overwritten.
   =20
    This regression was introduced in commit d47a61aa
    "ath9k: Fix multi-VIF BSS handling"
   =20
    Signed-off-by: Felix Fietkau <nbd@openwrt.org>
    Reported-by: Thomas H=FChn <thomas@net.t-labs.tu-berlin.de>
    Acked-by: Sujith Manoharan <c_manoha@qca.qualcomm.com>
    Cc: stable@vger.kernel.org [3.4]
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

To be clear, this is not a Cc: in the e-mail but instead a
Cc line in the commit log entry.

  Luis
