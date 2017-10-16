From: =?UTF-8?Q?Martin_Hundeb=c3=b8ll?= <mnhu@prevas.dk>
Subject: Re: [PATCH net-next] dsa: slave: support phy devices on external MII
 bus
Date: Mon, 16 Oct 2017 14:48:23 +0200
Message-ID: <74469237-cea3-1eb6-1bd6-8d7ee55a8af5@prevas.dk>
References: <20171016104525.26810-1-mnhu@prevas.dk>
 <20171016124002.GE4255@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="------------5EAE2436FB945F62C86B13F0"
Cc: "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:2193 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752501AbdJPMsY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 08:48:24 -0400
In-Reply-To: <20171016124002.GE4255@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--------------5EAE2436FB945F62C86B13F0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

Hi Andrew,

On 2017-10-16 14:40, Andrew Lunn wrote:
>>        /* internal MII */
>>        mdio {
>>          switch0phy1@1 {
>>            reg = <1>;
>>          };
>>        };
>>
>>        /* external MII */
>>        mdio1 {
>>          switch0phy0: switch0phy0@0 {
>>            reg = <0>;
>>          };
> 
> Hi Martin
> 
> You are missing a compatible string here. The binding document says:
> 
> - mdio?         : Container of PHYs and devices on the external MDIO
>                            bus. The node must contains a compatible string of
>                            "marvell,mv88e6xxx-mdio-external"
> 
> 	  Andrew
> 

Yeah, I have it in my full dts file (attached snippet), but decided to 
limit the commit-message version to keep it short(er). Should I update 
the commit message to avoid confusing others?

The issue is really that dsa_slave_phy_connect() always uses the the 
mdio bus associated with struct dsa_switch, even when the phy-handle 
refers to a phy from another mdio bus.

Or am I missing something ?

// Martin

--------------5EAE2436FB945F62C86B13F0
Content-Type: audio/vnd.dts; name="armada-388-gp.dts"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="armada-388-gp.dts"

CQkJbWRpb0A3MjAwNCB7CgkJCQlwaW5jdHJsLW5hbWVzID0gImRlZmF1bHQiOwoJCQkJcGlu
Y3RybC0wID0gPCZtZGlvX3BpbnM+OwoKCQkJCXBoeTA6IGV0aGVybmV0LXBoeUAxIHsKCQkJ
CQlyZWcgPSA8MT47CgkJCQl9OwoKCQkJCXBoeTE6IGV0aGVybmV0LXBoeUAwIHsKCQkJCQly
ZWcgPSA8MD47CgkJCQl9OwoKCQkJCXN3aXRjaDA6IHN3aXRjaEAyIHsKCQkJCQljb21wYXRp
YmxlID0gIm1hcnZlbGwsbXY4OGU2MTkwIjsKCQkJCQlyZWcgPSA8Mj47CgkJCQkJZWVwcm9t
LWxlbmd0aCA9IDw2NTUzNj47CgkJCQkJI2FkZHJlc3MtY2VsbHMgPSA8MT47CgkJCQkJI3Np
emUtY2VsbHMgPSA8MD47CgoJCQkJCXBvcnRzIHsKCQkJCQkJI2FkZHJlc3MtY2VsbHMgPSA8
MT47CgkJCQkJCSNzaXplLWNlbGxzID0gPDA+OwoKCQkJCQkJcG9ydEAwIHsKCQkJCQkJCXJl
ZyA9IDwwPjsKCQkJCQkJCWxhYmVsID0gImxhbjAiOwoJCQkJCQkJcGh5LWhhbmRsZSA9IDwm
c3dpdGNoMHBoeTA+OwoJCQkJCQl9OwoKCQkJCQkJcG9ydEAxIHsKCQkJCQkJCXJlZyA9IDwx
PjsKCQkJCQkJCWxhYmVsID0gImxhbjEiOwoJCQkJCQkJcGh5LWhhbmRsZSA9IDwmc3dpdGNo
MHBoeTE+OwoJCQkJCQl9OwoKCQkJCQkJcG9ydEAyIHsKCQkJCQkJCXJlZyA9IDwyPjsKCQkJ
CQkJCWxhYmVsID0gImxhbjIiOwoJCQkJCQkJcGh5LWhhbmRsZSA9IDwmc3dpdGNoMHBoeTI+
OwoJCQkJCQl9OwoKCQkJCQkJcG9ydEAzIHsKCQkJCQkJCXJlZyA9IDwzPjsKCQkJCQkJCWxh
YmVsID0gImxhbjMiOwoJCQkJCQkJcGh5LWhhbmRsZSA9IDwmc3dpdGNoMHBoeTM+OwoJCQkJ
CQl9OwoKCQkJCQkJcG9ydEA0IHsKCQkJCQkJCXJlZyA9IDw0PjsKCQkJCQkJCWxhYmVsID0g
ImxhbjQiOwoJCQkJCQkJcGh5LWhhbmRsZSA9IDwmc3dpdGNoMHBoeTQ+OwoJCQkJCQl9OwoK
CQkJCQkJcG9ydEA1IHsKCQkJCQkJCXJlZyA9IDw1PjsKCQkJCQkJCWxhYmVsID0gImxhbjUi
OwoJCQkJCQkJcGh5LWhhbmRsZSA9IDwmc3dpdGNoMHBoeTU+OwoJCQkJCQl9OwoKCQkJCQkJ
cG9ydEA2IHsKCQkJCQkJCXJlZyA9IDw2PjsKCQkJCQkJCWxhYmVsID0gImxhbjYiOwoJCQkJ
CQkJcGh5LWhhbmRsZSA9IDwmc3dpdGNoMHBoeTY+OwoJCQkJCQl9OwoKCQkJCQkJcG9ydEA3
IHsKCQkJCQkJCXJlZyA9IDw3PjsKCQkJCQkJCWxhYmVsID0gImxhbjciOwoJCQkJCQkJcGh5
LWhhbmRsZSA9IDwmc3dpdGNoMHBoeTc+OwoJCQkJCQl9OwoKCQkJCQkJcG9ydEA4IHsKCQkJ
CQkJCXJlZyA9IDw4PjsKCQkJCQkJCWxhYmVsID0gImxhbjgiOwoJCQkJCQkJcGh5LWhhbmRs
ZSA9IDwmc3dpdGNoMHBoeTg+OwoJCQkJCQl9OwoKCQkJCQkJcG9ydEA5IHsKCQkJCQkJCXJl
ZyA9IDw5PjsKCQkJCQkJCWxhYmVsID0gImNwdSI7CgkJCQkJCQlwaHktbW9kZSA9ICJzZ21p
aSI7CgkJCQkJCQlldGhlcm5ldCA9IDwmZXRoMj47CgoJCQkJCQkJZml4ZWQtbGluayB7CgkJ
CQkJCQkJc3BlZWQgPSA8MTAwMD47CgkJCQkJCQkJZnVsbC1kdXBsZXg7CgkJCQkJCQl9OwoJ
CQkJCQl9OwoJCQkJCX07CgoJCQkJCW1kaW8gewoJCQkJCQkjYWRkcmVzcy1jZWxscyA9IDwx
PjsKCQkJCQkJI3NpemUtY2VsbHMgPSA8MD47CgoJCQkJCQlzd2l0Y2gwcGh5MTogc3dpdGNo
MHBoeTFAMSB7CgkJCQkJCQlyZWcgPSA8MT47CgkJCQkJCX07CgoJCQkJCQlzd2l0Y2gwcGh5
Mjogc3dpdGNoMHBoeTJAMiB7CgkJCQkJCQlyZWcgPSA8Mj47CgkJCQkJCX07CgoJCQkJCQlz
d2l0Y2gwcGh5Mzogc3dpdGNoMHBoeTNAMyB7CgkJCQkJCQlyZWcgPSA8Mz47CgkJCQkJCX07
CgoJCQkJCQlzd2l0Y2gwcGh5NDogc3dpdGNoMHBoeTRANCB7CgkJCQkJCQlyZWcgPSA8ND47
CgkJCQkJCX07CgoJCQkJCQlzd2l0Y2gwcGh5NTogc3dpdGNoMHBoeTVANSB7CgkJCQkJCQly
ZWcgPSA8NT47CgkJCQkJCX07CgoJCQkJCQlzd2l0Y2gwcGh5Njogc3dpdGNoMHBoeTZANiB7
CgkJCQkJCQlyZWcgPSA8Nj47CgkJCQkJCX07CgoJCQkJCQlzd2l0Y2gwcGh5Nzogc3dpdGNo
MHBoeTdANyB7CgkJCQkJCQlyZWcgPSA8Nz47CgkJCQkJCX07CgoJCQkJCQlzd2l0Y2gwcGh5
ODogc3dpdGNoMHBoeThAOCB7CgkJCQkJCQlyZWcgPSA8OD47CgkJCQkJCX07CgkJCQkJfTsK
CgkJCQkJbWRpbzEgewoJCQkJCQljb21wYXRpYmxlID0gIm1hcnZlbGwsbXY4OGU2eHh4LW1k
aW8tZXh0ZXJuYWwiOwoJCQkJCQkjYWRkcmVzcy1jZWxscyA9IDwxPjsKCQkJCQkJI3NpemUt
Y2VsbHMgPSA8MD47CgoJCQkJCQlzd2l0Y2gwcGh5MDogc3dpdGNoMHBoeTBAMCB7CgkJCQkJ
CQlyZWcgPSA8MD47CgkJCQkJCX07CgkJCQkJfTsKCQkJCX07CgkJCX07Cg==
--------------5EAE2436FB945F62C86B13F0--
