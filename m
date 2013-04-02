From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: firewire net, ipv4 arp: Extend hardware address and remove
 driver-level packet inspection.
Date: Tue, 2 Apr 2013 09:36:41 +0300
Message-ID: <20130402063641.GB4826@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kbuild@01.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36677 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab3DBGip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 02:38:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E,

The patch 6752c8db8e0c: "firewire net, ipv4 arp: Extend hardware=20
address and remove driver-level packet inspection." from Mar 25,=20
2013, leads to the following warning:
"drivers/firewire/net.c:278 fwnet_header_parse()
	 error: memcpy() 'haddr' too small (8 vs 16)"

drivers/firewire/net.c
   276  static int fwnet_header_parse(const struct sk_buff *skb, unsign=
ed char *haddr)
   277  {
   278          memcpy(haddr, skb->dev->dev_addr, FWNET_ALEN);
                                                  ^^^^^^^^^^
We bumped this to 16 bytes and made the fwnet_header and fwnet_hwaddr
structs bigger.  But according to Smatch this is still an 8 byte buffer
here.  Either phw.hw_addr or sll->sll_addr.

The call tree would be:
-> packet_rcv()
   -> dev_parse_header()
      -> fwnet_header_parse()

   279 =20
   280          return FWNET_ALEN;
   281  }
   282 =20

regards,
dan carpenter
