From: <zyjzyj2000@gmail.com>
Subject: ixgbe: get link speed as a slave nic unrelated with link
Date: Mon, 1 Feb 2016 15:27:54 +0800
Message-ID: <1454311675-24676-1-git-send-email-zyjzyj2000@gmail.com>
References: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <zyjzyj2000@gmail.com>, <emil.s.tantilov@intel.com>,
	<phillip.j.schmitt@intel.com>, <jeffrey.t.kirsher@intel.com>,
	<netdev@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<Boris.Shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57614 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbcBAH0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 02:26:03 -0500
In-Reply-To: <1452258030-63996-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Emil

Thanks for your patch.
After I applied your patch, the following are the feedback from my user=
s.

"
Users had tested the latest patch that you provided and it is much impr=
oved now. However it=E2=80=99s still not good enough as the users are p=
lanning field deployment. Here are their findings:

So close, but not quite 100%. I did run over 2500 re-negotiations on on=
e interface of a bonded pair and got the 0 MBps status total of three t=
imes. The longest run without single error was something like 1800 re-n=
egotiations or so. So, this version seems to improve the situation imme=
nsely (the unpatched driver fails like 25% of the time), but there stil=
l seems to remain some tiny race somewhere.

So  it seems the failure occurs once every 600-900 connections.
"

I delved into the source code. And I found that maybe this time slice c=
an result in this problem.

bonding                ixgbe=20
  |                     |
  |                    carrier_on
  |                     |
  |    <----------------|
 link_up                |
  |                     |
  |                    carrier_off
  |                     |
 get_link_speed ------->|
  |                     |

Now bonding driver is link up while speed is link_speed_unknown because=
 of link flap.

To an independent nic, it is meaningless to get link speed while carrie=
r is off. But to a slave nic, maybe it is helpful, especially nic link =
flaps.

Maybe this patch can fix the above time slice.

Any reply is appreciated.

Best Regards!
Zhu Yanjun
