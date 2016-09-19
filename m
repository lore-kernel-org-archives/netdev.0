From: Allan Nielsen <Allan.Nielsen@microsemi.com>
Subject: Requesting guidance on how to expose (new/exotic) PHY features to
 user-space
Date: Mon, 19 Sep 2016 08:46:16 +0000
Message-ID: <66E0C71AC771CF4297D4A99D55E55AB84EA675CA@avsrvexchmbx2.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0051.outbound.protection.outlook.com ([104.47.32.51]:57365
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752502AbcISOV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 10:21:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,=0A=
=0A=
I'm working with Raju to create Open Source driver (and to get them accepte=
d=0A=
upstream) for Microsemi PHYs.=0A=
=0A=
First of all, thanks a lot for all the comments and all the help you (and=
=0A=
others) are providing. It is hard to see such a community working without p=
eople=0A=
like you - you are doing a great job :-D=0A=
=0A=
Both Raju and I are used to hacking the Linux kernel, but it we are not use=
d to=0A=
getting drivers accepted upstream - so as you can see, we are learning...=
=0A=
=0A=
I think that a bit general guidance could help us producing better patches,=
 and=0A=
thereby also save some of your time.=0A=
=0A=
Before jumping to the questions, I like to explain the context we are comin=
g=0A=
from. MSCC is (among many other things) designing PHY's and Switch fabrics.=
 We=0A=
are creating and supporting both drivers and "turn-key like" SW both for th=
e=0A=
PHYs and switches. We have mainly been using eCos for a long time, but ~1 y=
ear=0A=
ago we replaced eCos with Linux.=0A=
=0A=
In the current SW model, most SW runs in user-space and is proprietary. But=
 we=0A=
are working more and more in the direction of Open Sourcing certain part of=
 the=0A=
SW, and the company is becoming more and more aware of the advantage of doi=
ng=0A=
open-source SW and getting it accepted upstream. In recent events we have=
=0A=
released the API (driver layer) for the user-space application under the MI=
T=0A=
license (covering a large range of PHYs and Switches).=0A=
=0A=
The project Raju is working on is about getting support for some of the PHY=
s=0A=
accepted upstream.=0A=
=0A=
One of the challenges that Raju (and I) is facing is that the ambitions is =
to=0A=
implement the same set of features in the upstream Linux driver as we=0A=
currently support in the MIT and proprietary version.=0A=
=0A=
Features that already exists in some of the drivers should be okay. In thes=
e=0A=
cases it is just about adjusting our implementation to use the existing=0A=
configuration channels (IOCTL, various structs in phy.h, device-tree etc).=
=0A=
=0A=
But we also have a hand-full of features that is hard to fit in, and we are=
=0A=
seeking some advice on how to handle those.=0A=
=0A=
It typically boils down to finding a good way of exposing such a feature to=
 a=0A=
given user-space application.=0A=
=0A=
A good example of this could be a feature that internally is being called=
=0A=
VeriPHY. The idea of this is that the PHY can run some diagnostic and figur=
e out=0A=
if there is a damage to the cable, and it can estimate where the damage is.=
=0A=
=0A=
What is the preferred way of exposing such a feature??=0A=
=0A=
Here are some of the options we have considered:=0A=
=0A=
- Keeping such "exotic" features in user-space. This will require register=
=0A=
  access to the PHY from user-space. And as this feature is using "non-stan=
dard"=0A=
  pages we need something similar to SIOCGMIIREG/SIOCSMIIREG, but which sup=
ports=0A=
  registers in different pages.=0A=
- Adding new IOCTL's for exposing this feature.=0A=
- Add a netlink interface=0A=
- Add a sysfs interface=0A=
=0A=
Please let me know what you think...=0A=
=0A=
Best regards=0A=
Allan W. Nielsen=0A=
=0A=
