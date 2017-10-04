From: =?ISO-8859-15?Q?J=F6rg_Willmann?= <joe@clnt.de>
Subject: Re: etsec2 attached to sgmii phy
Date: Wed, 4 Oct 2017 16:19:23 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1710041613320.9785@brian.int1.clnt.de>
References: <alpine.DEB.2.20.1710040756160.31757@brian.int1.clnt.de> <20171004133642.GM30045@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="8323329-1421196961-1507126763=:9785"
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay07.ispgateway.de ([134.119.228.100]:8506 "EHLO
        smtprelay07.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751176AbdJDOT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 10:19:27 -0400
In-Reply-To: <20171004133642.GM30045@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--8323329-1421196961-1507126763=:9785
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Wed, 4 Oct 2017, Andrew Lunn wrote:

> On Wed, Oct 04, 2017 at 07:56:53AM +0200, Jörg Willmann wrote:
>> Hi,
>>
>> we use a QorIQ P1011 connected via SGMII to a switch (Marvell 88E6352).
>> Currently we still use a really old linux kernel (2.6.33) successfully.
>>
>> For configuration of the MDIO Bus attached to the corresponding eTSEC/TBI
>> Phy we use the following settings in the device tree:
>>
>>                         mdio@25000 {
>>                                    #address-cells = <0x1>;
>>                                    #size-cells = <0x0>;
>>                                    compatible = "fsl,etsec2-tbi";
>>                                    reg = <0x25000 0x1000 0xb1030 0x4>;
>
> Hi Joerg
>
> Is 0xb1030 0x4 fixed by the silicon? Can it be expressed as an offset from
> 0x25000?
>
> It seems like the idea behind the patch is to hard code some
> things. If you can hard code the offset into get_etsec_tbipa(), i
> think that would be an O.K. solution to your problem.
>
>      Andrew
>
Yes, the adress 0xb1030 is fixed but it's something totally different than 
the address range of 0x25000. 0xb0000, 0xb1000 and 0xb2000 are base 
addresses of the eTSEC MAC (TPIPA is a register within the MAC) and 
0x24000, 0x25000 and 0x26000 are the base registers of the corresponding 
MDIO controllers. So I wouldn't add a dependency between these two things.
>From my point of view, the implementation in the old kernel where 
get_gfar_tbipa() got the device tree node pointer as argument was not soo 
bad ;-)

 	Joerg
--8323329-1421196961-1507126763=:9785--
