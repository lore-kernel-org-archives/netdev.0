From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net-next.git) 2/2] stmmac: fix MDIO settings
Date: Wed, 16 Mar 2016 13:53:47 +0100
Message-ID: <56E9575B.5020702@st.com>
References: <1458121942-5537-1-git-send-email-peppe.cavallaro@st.com> <1458121942-5537-3-git-send-email-peppe.cavallaro@st.com> <CAG374jDJS7TUSx0Ob38x4aRYHyrA+OWeCDm+f-Ytq8YZhwkEqg@mail.gmail.com> <56E93D72.7060106@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <fschaefer.oss@googlemail.com>,
	Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Phil Reid <preid@electromag.com.au>
To: =?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber@suse.de>,
	Gabriel Fernandez <gabriel.fernandez@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:44037 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754151AbcCPMx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 08:53:59 -0400
In-Reply-To: <56E93D72.7060106@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

On 3/16/2016 12:03 PM, Andreas F=C3=A4rber wrote:
> Am 16.03.2016 um 12:01 schrieb Gabriel Fernandez:
>> Hi Pepe,
>>
>> i have a kernel crash
>>
>> [    2.714097] Unable to handle kernel NULL pointer dereference at
>> virtual address 000001d6
>> [    2.722188] pgd =3D c0204000
>> [    2.724886] [000001d6] *pgd=3D00000000
>> [    2.728452] Internal error: Oops: 5 [#1] SMP ARM
>> [    2.733054] Modules linked in:
>> [    2.736095] CPU: 1 PID: 1 Comm: swapper/0 Not tainted
>> 4.5.0-rc7-01768-g3407893 #36
>> [    2.743649] Hardware name: STiH415/416 SoC with Flattened Device =
Tree
>> [    2.750074] task: ee070000 ti: ee05e000 task.ti: ee05e000
>> [    2.755467] PC is at stmmac_open+0xcc/0xc40
>> [    2.759641] LR is at of_phy_connect+0x44/0x5c
>>
>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/dr=
ivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> index 4c5ce98..943500b 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>>> @@ -278,7 +278,6 @@ static void stmmac_eee_ctrl_timer(unsigned long=
 arg)
>>>    */
>>>   bool stmmac_eee_init(struct stmmac_priv *priv)
>>>   {
>>> -       char *phy_bus_name =3D priv->plat->phy_bus_name;
>>>          unsigned long flags;
>>>          bool ret =3D false;
>>>
>>> @@ -290,7 +289,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>>>                  goto out;
>>>
>>>          /* Never init EEE in case of a switch is attached */
>>> -       if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
>>> +       if (priv->phydev->is_pseudo_fixed_link)
>>
>> priv->phydev is not yet affected
>> replace by if (phydev->is_pseudo_fixed_link) instead ?
>
> Indeed that's how I had it in my own patch before. Thanks for spottin=
g.


thanks for spotting and I have just sent the V2 of these patches
and I have understood why I did not catch it on my test :-(
my fault, sorry !

Cheers
Peppe

>
> Regards,
> Andreas
>
