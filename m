From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber@suse.de>
Subject: Re: [PATCHv3 (net.git) 2/2] stmmac: fix MDIO settings
Date: Wed, 16 Mar 2016 10:47:27 +0100
Message-ID: <56E92BAF.3020001@suse.de>
References: <1457703196-15008-1-git-send-email-peppe.cavallaro@st.com>
 <1457703196-15008-3-git-send-email-peppe.cavallaro@st.com>
 <56E75D36.2030201@suse.de> <56E82FF3.5010402@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gabriel.fernandez@linaro.org,
	fschaefer.oss@googlemail.com, dinh.linux@gmail.com,
	davem@davemloft.net, preid@electromag.com.au,
	Tomeu Vizoso <tomeu@tomeuvizoso.net>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54370 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753912AbcCPJrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 05:47:32 -0400
In-Reply-To: <56E82FF3.5010402@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peppe,

Am 15.03.2016 um 16:53 schrieb Giuseppe CAVALLARO:
> On 3/15/2016 1:54 AM, Andreas F=C3=A4rber wrote:
>> The connectivity issue still remains. Kernel log snippet:
>>
>> [  +0.001117] rk_gmac-dwmac ff290000.ethernet: Looking up phy-supply
>> from device tree
>> [  +0.000028] rk808 0-001b: Looking up vcc12-supply from device tree
>> [  +0.000014] vcc_lan: supplied by vcc_io
>> [  +0.000101] rk_gmac-dwmac ff290000.ethernet: clock input or output=
?
>> (input).
>> [  +0.000009] rk_gmac-dwmac ff290000.ethernet: TX delay(0x30).
>> [  +0.000008] rk_gmac-dwmac ff290000.ethernet: RX delay(0x10).
>> [  +0.000014] rk_gmac-dwmac ff290000.ethernet: init for RGMII
>> [  +0.000104] rk_gmac-dwmac ff290000.ethernet: clock input from PHY
>> [  +0.005063] rk_gmac-dwmac ff290000.ethernet: no reset control foun=
d
>> [  +0.000007] stmmac - user ID: 0x10, Synopsys ID: 0x35
>> [  +0.000002]  Ring mode enabled
>> [  +0.000006]  DMA HW capability register supported
>> [  +0.000000]  Normal descriptors
>=20
>                  ^^^^^^^^^^^^^^^^^^
>=20
>> [  +0.000003]  RX Checksum Offload Engine supported (type 2)
>> [  +0.000002]  TX Checksum insertion supported
>> [  +0.000002]  Wake-Up On Lan supported
>> [  +0.000053]  Enable RX Mitigation via HW Watchdog Timer
>> [  +0.000771] of_get_named_gpiod_flags: can't parse 'snps,reset-gpio=
'
>> property of node '/ethernet@ff290000[0]'
>> [  +0.004250] libphy: stmmac: probed
>> [  +0.000009] eth0: PHY ID 001cc915 at 0 IRQ POLL (stmmac-0:00) acti=
ve
>> [  +0.000005] eth0: PHY ID 001cc915 at 1 IRQ POLL (stmmac-0:01)
>>
>> As before, reverting "stmmac: first frame prep at the end of xmit
>> routine" fixes it. My test cases are `ping 192.168.1.1` and `zypper =
up`.
>=20
> so on your side, this revert fixes the issue and you do not see any
> tx watchdog as Tomeu's raised.

Confirmed, the system ran stable over night. I don't use NFS on that
system myself, having GMAC working only since v2.

> I have fixed some problems on top of
> "stmmac: first frame prep at the end of xmit ..." please
> see patch attached for net-next.
>=20
> Indeed, the normal tx descriptors are well filled w/o
> "stmmac: first frame prep at the end of xmit ..."
>=20
> I wonder if you could try the attachment in order to understand if we
> have to  actually revert the patch (I ask you to not revert the
> patch "stmmac: first frame...").

Works great on top of next-20160314 with i2c plus this series, please
add my Tested-by. Thanks a lot for investigating!

Cheers,
Andreas

--=20
SUSE Linux GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg, Germany
GF: Felix Imend=C3=B6rffer, Jane Smithard, Graham Norton; HRB 21284 (AG=
 N=C3=BCrnberg)
