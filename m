From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 09/14] net: Rework gianfar driver to use of_mdio
	infrastructure.
Date: Sat, 18 Apr 2009 00:34:05 -0600
Message-ID: <fa686aa40904172334g2c989765u3ae9c3e50b7ad5c4@mail.gmail.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	<20090331082730.1427.96418.stgit@localhost.localdomain> <E3135C12-C512-43CF-B30D-B3AF7D7DE181@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, olof@lixom.net,
	galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:57241 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbZDRGeV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 02:34:21 -0400
Received: by yx-out-2324.google.com with SMTP id 3so316192yxj.1
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 23:34:20 -0700 (PDT)
In-Reply-To: <E3135C12-C512-43CF-B30D-B3AF7D7DE181@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 15, 2009 at 5:01 PM, Andy Fleming <afleming@freescale.com> =
wrote:
>
> On Mar 31, 2009, at 3:27 AM, Grant Likely wrote:
>
>> From: Grant Likely <grant.likely@secretlab.ca>
>>
>> This patch simplifies the driver by making use of more common code.
>>
>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>> ---
>>
>> drivers/net/gianfar.c | =A0103
>> ++++++++++++++++++-------------------------------
>> drivers/net/gianfar.h | =A0 =A03 +
>> 2 files changed, 40 insertions(+), 66 deletions(-)
>>
>>
>> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
>> index 65f5587..c22eba9 100644
>> @@ -699,23 +657,38 @@ static int init_phy(struct net_device *dev)
>>
>>
>> + =A0 =A0 =A0 if (priv->tbi_node) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tbiphy =3D of_phy_connect(dev, p=
riv->tbi_node,
>> &adjust_link,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 0, interface);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!priv->tbiphy) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "er=
ror: Could not attach to
>> TBI\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err_tbiphy;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>
> I don't believe we need this. =A0Certainly, the current code doesn't =
do
> anything like this. =A0The TBI node is a special internal PHY used to=
 manage
> SGMII/TBI links.

Actually, it does.  gianfar_of_init() used to parse the tbi-handle,
and I've replaced that code with a call to of_parse_phandle() in init
and an of_phy_connect() in init_phy() to get a pointer to the TBI
phy_device.  However, you are completely right that calling
of_phy_connect() is entirely the wrong thing to do on the TBI phy.  It
should be retrieving the pointer to the phydevice without actually
connecting to it (which forces the phy_driver probe and starts the
state machine).  I need to fix this.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
