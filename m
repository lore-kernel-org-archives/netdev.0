From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Bonding driver problem
Date: Mon, 25 Feb 2013 23:18:35 +0100
Message-ID: <20130225221835.GA1730@minipsycho.orion>
References: <20130225141008.00004621@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sibai.li@intel.com
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:42906 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758924Ab3BYWSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 17:18:39 -0500
Received: by mail-ee0-f48.google.com with SMTP id t10so1792571eei.21
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 14:18:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130225141008.00004621@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Feb 25, 2013 at 11:10:08PM CET, gregory.v.rose@intel.com wrote:
>
>We're having some problems with the following commit:
>
>commit 409cc1f8a4149c26bbb8e5d3bacb36541ad371e2
>Author: Jiri Pirko <jiri@resnulli.us>
>Date:   Wed Jan 30 11:08:11 2013 +0100
>
>    bond: have random dev address by default instead of zeroes
>   =20
>    Makes more sense to have randomly generated address by default tha=
n to
>    have all zeroes. It also allows user to for example put the bond i=
nto
>    bridge without need to have any slaves in it.
>   =20
>    Also note that this changes only behaviour of bonds with no slaves=
=2E Once
>    the first slave device is enslaved, its address will be used (no c=
hange
>    here).
>   =20
>    Also, fix dev_assign_type values on the way.
>   =20
>    Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
>    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>    Signed-off-by: David S. Miller <davem@davemloft.net>
>
>According to our tester, Sibai, before the patch, the mac of bonding
>device is assigned by default as zero when it has no slave. Once the
>first slave is enslaved, the bonding device takes the mac of first
>slave, then passes this mac to all slaves.=20
>
>But with this patch, the mac of the bonding interface is assigned a
>random mac, and when the slave device is enslaved, the bonding device
>keeps taking the mac of the slave it last enslaved. And former enslave=
d
>slaves keep reverting to their original mac.  So for  mode 1, since th=
e
>first slave is the active one, the rest of the slaves are the backup,
>because the mac of bonding is different than the first slave, so the
>bonding device cannot receive packets.

I think I know what is the issue. bond->dev_addr_from_first should be
set to false in bond_enslave. I will fix this tomorrow. Sorry for the
inconvenience.


>
>When we tried test build that reverted this patch the issue she was
>seeing went away and the bonding worked the she was accustomed to.
>
>This may be deliberate and we may have to change our test procedures
>but we wanted to make sure.
>
>The specific use case is to use a two virtual functions each from a
>different physical function port to create fail over bonding.
>
>Thanks,
>
>- Greg Rose
>Networking Division
>Intel Corp.
