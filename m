From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800 driver
Date: Fri, 05 Feb 2016 15:26:30 +0000
Message-ID: <yw1xbn7vgoux.fsf@unicorn.mansr.com>
References: <56B4A445.7080402@laposte.net>
	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>
	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net>
	<yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net>
	<yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net>
	<yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:53629 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751798AbcBEP0d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 10:26:33 -0500
In-Reply-To: <56B4BDDA.9010708@laposte.net> (Sebastian Frias's message of
	"Fri, 05 Feb 2016 16:20:58 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Frias <sf84@laposte.net> writes:

> On 02/05/2016 04:08 PM, M=E5ns Rullg=E5rd wrote:
>> Sebastian Frias <sf84@laposte.net> writes:
>>
>>> On 02/05/2016 03:34 PM, M=E5ns Rullg=E5rd wrote:
>>>> Sebastian Frias <sf84@laposte.net> writes:
>>>>
>>>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>>>
>>>> Please change the subject to something like "net: ethernet: nb8800=
:
>>>> support fixed-link DT node" and add a comment body.
>>>
>>> The subject is pretty explicit for such a simple patch, what else
>>> could I add that wouldn't be unnecessary chat?
>>
>> It's customary to include a description body even if it's little mor=
e
>> than a restatement of the subject.  Also, while the subject usually =
only
>> says _what_ the patch does, the body should additionally state _why_=
 it
>> is needed.
>
> I understand, but _why_ it is needed is also obvious in this case; I
> mean, without the patch "fixed-link" cannot be used.

Then say so.

> Other patches may not be as obvious/simple and thus justify and
> require more details.
>
> Anyway, I added "Properly handles the case where the PHY is not conne=
cted
> to the real MDIO bus" would that be ok?

Have you read Documentation/SubmittingPatches?  Do so (again) and pay
special attention to section 2 "Describe your changes."

>>>>> ---
>>>>>    drivers/net/ethernet/aurora/nb8800.c | 14 +++++++++++++-
>>>>>    1 file changed, 13 insertions(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c
>>>>> b/drivers/net/ethernet/aurora/nb8800.c
>>>>> index ecc4a33..e1fb071 100644
>>>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>>>> @@ -1460,7 +1460,19 @@ static int nb8800_probe(struct platform_de=
vice *pdev)
>>>>>    		goto err_disable_clk;
>>>>>    	}
>>>>>
>>>>> -	priv->phy_node =3D of_parse_phandle(pdev->dev.of_node, "phy-han=
dle", 0);
>>>>> +	if (of_phy_is_fixed_link(pdev->dev.of_node)) {
>>>>> +		ret =3D of_phy_register_fixed_link(pdev->dev.of_node);
>>>>> +		if (ret < 0) {
>>>>> +			dev_err(&pdev->dev, "bad fixed-link spec\n");
>>>>> +			goto err_free_bus;
>>>>> +		}
>>>>> +		priv->phy_node =3D of_node_get(pdev->dev.of_node);
>>>>> +	}
>>>>> +
>>>>> +	if (!priv->phy_node)
>>>>> +		priv->phy_node =3D of_parse_phandle(pdev->dev.of_node,
>>>>> +						  "phy-handle", 0);
>>>>> +
>>>>>    	if (!priv->phy_node) {
>>>>>    		dev_err(&pdev->dev, "no PHY specified\n");
>>>>>    		ret =3D -ENODEV;
>>>>> --
>>>>> 2.1.4
>>>>
>>

--=20
M=E5ns Rullg=E5rd
