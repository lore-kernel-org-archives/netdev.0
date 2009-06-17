From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH][Resend 2][BUILD FAILURE 04/04] Next June 04:PPC64
	randconfig [drivers/net/ucc_geth.o]
Date: Wed, 17 Jun 2009 14:37:38 -0600
Message-ID: <fa686aa40906171337n13813d9wddaa03f2e8904f80@mail.gmail.com>
References: <20090611033705.20842.75501.sendpatchset@subratamodak.linux.ibm.com>
	<1245048719.5239.10.camel@subratamodak.linux.ibm.com> <1245243097.4870.3.camel@subratamodak.linux.ibm.com>
	<6E26D0A1-0FE5-4179-9DA8-FDF0E3D417DA@kernel.crashing.org>
	<20090617232341.c4543ff2.sfr@canb.auug.org.au> <20090617233452.03ac78d5.sfr@canb.auug.org.au>
	<fa686aa40906171029p4d5b876fm16d0f144b1a19346@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kumar Gala <galak@kernel.crashing.org>, subrata@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	Nathan Lynch <ntl@pobox.com>,
	Sachin P Sant <sachinp@linux.vnet.ibm.com>,
	Linux-Next <linux-next@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>,
	Balbir Singh <balbir@linux.vnet.ibm.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Tony Breeds <tony@bakeyournoodle.com>, michael@ellerman.id.au,
	Haiying Wang <Haiying.Wang@freescale.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:48339 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbZFQUh4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 16:37:56 -0400
In-Reply-To: <fa686aa40906171029p4d5b876fm16d0f144b1a19346@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 11:29 AM, Grant Likely<grant.likely@secretlab.c=
a> wrote:
> On Wed, Jun 17, 2009 at 7:34 AM, Stephen Rothwell<sfr@canb.auug.org.a=
u> wrote:
>> On Wed, 17 Jun 2009 23:23:41 +1000 Stephen Rothwell <sfr@canb.auug.o=
rg.au> wrote:
>>>
>>> Hi Kumar,
>>>
>>> On Wed, 17 Jun 2009 08:07:47 -0500 Kumar Gala <galak@kernel.crashin=
g.org> wrote:
>>> >
>>> >
>>> > I'm confused by the proposed fix as we already have *mdio & *ph
>>> > defined in this function:
>>>
>>> Which tree are you looking at? =A0Linus' tree, and linux-next, do n=
ot have
>>> those local variables ...
>>
>> Hmmm, commit 0b9da337dca972e7a4144e298ec3adb8f244d4a4 ("net: Rework
>> ucc_geth driver to use of_mdio infrastructure") removed the locals a=
long
>> with their usages, then commit 047584ce94108012288554a5f84585d792cc7=
f8f
>> ("net/ucc_geth: Add SGMII support for UEC GETH driver") added more u=
ses
>> without adding the variables back.
>>
>> Here is the patch again:
>>
>> From: Subrata Modak <subrata@linux.vnet.ibm.com>
>> Subject: [PATCH] Fix build error in ucc_geth.c
>>
>> Fix the following build error:
>>
>> drivers/net/ucc_geth.c: In function bucc_geth_probeb:
>> drivers/net/ucc_geth.c:3822: error: 'ph' undeclared (first use in th=
is function)
>> drivers/net/ucc_geth.c:3822: error: (Each undeclared identifier is r=
eported only once
>> drivers/net/ucc_geth.c:3822: error: for each function it appears in.=
)
>> drivers/net/ucc_geth.c:3832: error: 'mdio' undeclared (first use in =
this function)
>> make[2]: *** [drivers/net/ucc_geth.o] Error 1
>>
>> Signed-off-by: Subrata Modak <subrata@linux.vnet.ibm.com>
>>
>> --- linux-2.6.30-rc8/drivers/net/ucc_geth.c.orig =A0 =A0 =A0 =A02009=
-06-10 11:58:39.000000000 -0500
>> +++ linux-2.6.30-rc8/drivers/net/ucc_geth.c =A0 =A0 2009-06-10 22:28=
:13.000000000 -0500
>> @@ -3595,6 +3595,8 @@ static const struct net_device_ops ucc_g
>>
>> =A0static int ucc_geth_probe(struct of_device* ofdev, const struct o=
f_device_id *match)
>> =A0{
>> + =A0 =A0 =A0 struct device_node *mdio;
>> + =A0 =A0 =A0 const phandle *ph;
>> =A0 =A0 =A0 =A0struct device *device =3D &ofdev->dev;
>> =A0 =A0 =A0 =A0struct device_node *np =3D ofdev->node;
>> =A0 =A0 =A0 =A0struct net_device *dev =3D NULL;
>
> Ah, this might not be the right fix then. =A0I'll look.

Yeah, this is not the right fix.  The SGMII change doesn't mesh well
with the of_mdio changes and needed some rewriting.  I'm about to post
a patch (compile tested only) which should make things happy.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
