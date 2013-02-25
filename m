From: Greg Rose <gregory.v.rose@intel.com>
Subject: Bonding driver problem
Date: Mon, 25 Feb 2013 14:10:08 -0800
Message-ID: <20130225141008.00004621@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <sibai.li@intel.com>
To: <netdev@vger.kernel.org>, <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7536 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752361Ab3BYWKL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 17:10:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We're having some problems with the following commit:

commit 409cc1f8a4149c26bbb8e5d3bacb36541ad371e2
Author: Jiri Pirko <jiri@resnulli.us>
Date:   Wed Jan 30 11:08:11 2013 +0100

    bond: have random dev address by default instead of zeroes
   =20
    Makes more sense to have randomly generated address by default than=
 to
    have all zeroes. It also allows user to for example put the bond in=
to
    bridge without need to have any slaves in it.
   =20
    Also note that this changes only behaviour of bonds with no slaves.=
 Once
    the first slave device is enslaved, its address will be used (no ch=
ange
    here).
   =20
    Also, fix dev_assign_type values on the way.
   =20
    Reported-by: Pavel =C5=A0imerda <psimerda@redhat.com>
    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

According to our tester, Sibai, before the patch, the mac of bonding
device is assigned by default as zero when it has no slave. Once the
first slave is enslaved, the bonding device takes the mac of first
slave, then passes this mac to all slaves.=20

But with this patch, the mac of the bonding interface is assigned a
random mac, and when the slave device is enslaved, the bonding device
keeps taking the mac of the slave it last enslaved. And former enslaved
slaves keep reverting to their original mac.  So for  mode 1, since the
first slave is the active one, the rest of the slaves are the backup,
because the mac of bonding is different than the first slave, so the
bonding device cannot receive packets.

When we tried test build that reverted this patch the issue she was
seeing went away and the bonding worked the she was accustomed to.

This may be deliberate and we may have to change our test procedures
but we wanted to make sure.

The specific use case is to use a two virtual functions each from a
different physical function port to create fail over bonding.

Thanks,

- Greg Rose
Networking Division
Intel Corp.
