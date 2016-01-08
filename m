From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [RFC PATCH net-next] bonding: Use notifiers for slave link state detection
Date: Thu, 07 Jan 2016 22:12:50 -0800
Message-ID: <30904.1452233570@famine>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com> <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com> <16587.1452148421@famine> <27321.1452216515@famine> <568F3CDD.6040606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emil.s.tantilov@intel.com, mkubecek@suse.cz, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	boris.shteinbock@windriver.com
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:49276 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbcAHGM5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 01:12:57 -0500
In-reply-to: <568F3CDD.6040606@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

zhuyj <zyjzyj2000@gmail.com> wrote:

>Hi, Jay
>
>Thank for your help.
>I made a new patch based on the latest linux kernel. Now it is in the
>attachment.
>When I run "make", the following errors will pop up.
[...]
>drivers/net/bonding/bond_main.c:1996:3: error: too many arguments to
>function =E2=80=98bond_set_slave_link_state=E2=80=99
>include/net/bonding.h:507:20: note: declared here

	My patch was generated against the current net-next git
repository.  I suspect you're using an older kernel; since commit

5d397061ca20 ("bonding: allow notifications for bond_set_slave_link_sta=
te")

	the bond_set_slave_link_state function has three arguments.
This commit was added 3 Dec 2015.

	For example, from your patch:

>-			bond_set_slave_link_state(slave, BOND_LINK_FAIL);
[...]
>+		bond_set_slave_link_state(slave, BOND_LINK_FAIL, BOND_SLAVE_NOTIFY_=
LATER);

	For your kernel version, you'll need to change the patched code
to remove the third argument to bond_set_slave_link_state.

>And I can not find notifier callbacks in the patch.

	The bond_slave_netdev_event function is bonding's notifier
callback; the patch adds a call there for NETDEV_UP, NETDEV_CHANGE and
NETDEV_DOWN events to check link state:

> 	case NETDEV_DOWN:
>+		if (bond_miimon_inspect_slave(bond, slave))
>+			bond_miimon_commit(bond);
>+

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
