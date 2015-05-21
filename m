From: Casey Leedom <leedom@chelsio.com>
Subject: RE: [PATCH net-next 1/3] cxgb4: Add support for loopback between VI
 of same port
Date: Thu, 21 May 2015 16:36:00 +0000
Message-ID: <4985EFDD773FCB459EF7915D2A3621ADBD9FE5@nice.asicdesigners.com>
References: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
	<1431859523-7423-2-git-send-email-hariprasad@chelsio.com>,<20150517.234613.463972132331185537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: David Miller <davem@davemloft.net>,
	Hariprasad S <hariprasad@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4237 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755582AbbEUQil convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 12:38:41 -0400
In-Reply-To: <20150517.234613.463972132331185537.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller [davem@davemloft.net]
| Sent: Sunday, May 17, 2015 8:46 PM
|=20
| > From: Hariprasad Shenai <hariprasad@chelsio.com>
| > Date: Sun, 17 May 2015 16:15:21 +0530
| >=20
| > We now have a new cxgb4 module parameter "tx_vf" that when set
| > to a non-zero value, causes cxgb4 to use the "Virtual Machine" vers=
ion
| > of the firmware Ethernet TX Packet Work Request (FW_ETH_TX_PKT_VM_W=
R)
| > instead of the "normal" default non-VM Work Request (FW_ETH_TX_PKT_=
WR).
|=20
| Sorry, module parameters are veboten.
|=20
| Especially for settings like this which are guaranteed to be
| interesting for other NIC drivers, not just your's.
|=20
| I'm really tired of explaining this to driver authors.  Just
| don't even try to push a module parameter past me.

I definitely understand the issue of wanting to avoid randomly differen=
t module parameters in various drivers which do similar things.  What w=
e're looking for is a list of the acceptable ways for doing things =97 =
especially when they don't fit current ethtool/ioctl() mechanisms.

  A couple of specific examples:

 1. We need to load the driver and tell it _not_ to attempt to contact =
firmware on
    the adapter.  This is typically used to load firmware on a brand ne=
w adapter or
    debug a problem with the adapter without changing its existing stat=
e.  This need
    presents an awkward problem because we need to have the driver know=
 from
    the very start that it shouldn't try to communicate with the firmwa=
re, while our
    normal PCI probe() does in fact contact the firmware as part of the=
 probe ...

 2. This patch: We have the ability to use two fundamentally different =
TX Work
    Requests =97 one which causes the adapter firmware to check for loc=
al
    loopback delivery targets and one which doesn't.  Unlike the first =
example,
    this can be specified long after the adapter probe operation but it=
's unclear
    if there's any current ethtool/ioctl() which can be used for this. =
 Should we
    suggest a new ethtool operation like "TX Method"?

More generally, is there a document somewhere which already covers the =
suggested mechanisms for passing parameter information into network dri=
vers for different cases so we don't send in patch requests which waste=
 people's time?

Casey