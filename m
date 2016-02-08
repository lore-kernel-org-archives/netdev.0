From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH v3] net: ethernet: support "fixed-link" DT node on nb8800
 driver
Date: Mon, 08 Feb 2016 11:34:44 +0100
Message-ID: <56B86F44.3030806@laposte.net>
References: <56B4A445.7080402@laposte.net>	<yw1x1t8ri8dz.fsf@unicorn.mansr.com> <56B4A877.4020800@laposte.net>	<yw1xsi17gsxl.fsf@unicorn.mansr.com> <56B4ACC4.1000607@laposte.net>	<yw1xoabvgs7s.fsf@unicorn.mansr.com> <56B4B013.5030407@laposte.net>	<yw1xk2mjgraf.fsf@unicorn.mansr.com> <56B4B81D.3000108@laposte.net>	<yw1xfux7gpol.fsf@unicorn.mansr.com> <56B4BDDA.9010708@laposte.net> <yw1xbn7vgoux.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: =?windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <yw1xbn7vgoux.fsf@unicorn.mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/05/2016 04:26 PM, M=E5ns Rullg=E5rd wrote:
> Sebastian Frias <sf84@laposte.net> writes:
>
>> On 02/05/2016 04:08 PM, M=E5ns Rullg=E5rd wrote:
>>> Sebastian Frias <sf84@laposte.net> writes:
>>>
>>>> On 02/05/2016 03:34 PM, M=E5ns Rullg=E5rd wrote:
>>>>> Sebastian Frias <sf84@laposte.net> writes:
>>>>>
>>>>>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>>>>>
>>>>> Please change the subject to something like "net: ethernet: nb880=
0:
>>>>> support fixed-link DT node" and add a comment body.
>>>>
>>>> The subject is pretty explicit for such a simple patch, what else
>>>> could I add that wouldn't be unnecessary chat?
>>>
>>> It's customary to include a description body even if it's little mo=
re
>>> than a restatement of the subject.  Also, while the subject usually=
 only
>>> says _what_ the patch does, the body should additionally state _why=
_ it
>>> is needed.
>>
>> I understand, but _why_ it is needed is also obvious in this case; I
>> mean, without the patch "fixed-link" cannot be used.
>
> Then say so.
>
>> Other patches may not be as obvious/simple and thus justify and
>> require more details.
>>
>> Anyway, I added "Properly handles the case where the PHY is not conn=
ected
>> to the real MDIO bus" would that be ok?
>
> Have you read Documentation/SubmittingPatches?  Do so (again) and pay
> special attention to section 2 "Describe your changes."

I just sent v5.
If for whatever reason, you or anybody else think that the comment is=20
not good, would you mind proposing a comment that would make everybody=20
happy so that the patch goes thru?
And if you or anybody else does not want the patch, could you please sa=
y=20
so as well?

I have to admit this process (sending patches and getting it reviewed)=20
could benefit from more clarifications.
=46or example, the process could say that at least 2 reviewers must agr=
ee=20
on it (on the comments made to the patch and on the patch itself).
I could also say that reviewers are to express not only their opinion=20
but to clearly and unequivocally accept or reject.

=46or instance, right now, it is not clear to me if your comments are=20
"nice to have" or "blocking" the patch.
I don't know if the patch is welcome or not, etc.
So I submitted v5, but maybe it was not even necessary, it's hard to=20
know where in the submission process we are.

By the way, I know some people like the command line, email, etc. but=20
there ought to be other tools better suited for patch review...




>
>>>>>> ---
>>>>>>     drivers/net/ethernet/aurora/nb8800.c | 14 +++++++++++++-
>>>>>>     1 file changed, 13 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c
>>>>>> b/drivers/net/ethernet/aurora/nb8800.c
>>>>>> index ecc4a33..e1fb071 100644
>>>>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>>>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>>>>> @@ -1460,7 +1460,19 @@ static int nb8800_probe(struct platform_d=
evice *pdev)
>>>>>>     		goto err_disable_clk;
>>>>>>     	}
>>>>>>
>>>>>> -	priv->phy_node =3D of_parse_phandle(pdev->dev.of_node, "phy-ha=
ndle", 0);
>>>>>> +	if (of_phy_is_fixed_link(pdev->dev.of_node)) {
>>>>>> +		ret =3D of_phy_register_fixed_link(pdev->dev.of_node);
>>>>>> +		if (ret < 0) {
>>>>>> +			dev_err(&pdev->dev, "bad fixed-link spec\n");
>>>>>> +			goto err_free_bus;
>>>>>> +		}
>>>>>> +		priv->phy_node =3D of_node_get(pdev->dev.of_node);
>>>>>> +	}
>>>>>> +
>>>>>> +	if (!priv->phy_node)
>>>>>> +		priv->phy_node =3D of_parse_phandle(pdev->dev.of_node,
>>>>>> +						  "phy-handle", 0);
>>>>>> +
>>>>>>     	if (!priv->phy_node) {
>>>>>>     		dev_err(&pdev->dev, "no PHY specified\n");
>>>>>>     		ret =3D -ENODEV;
>>>>>> --
>>>>>> 2.1.4
>>>>>
>>>
>
