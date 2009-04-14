From: Gurucharan Shetty <Gurucharan.Shetty@riverbed.com>
Subject: Interface hang on nvidia MCP55 using forcedeth with stp packet
Date: Tue, 14 Apr 2009 12:13:20 -0700
Message-ID: <57AA7D7FD7A5A24EA0556701B6E03A2381BC8D23AE@MAILBOXES.nbttech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_57AA7D7FD7A5A24EA0556701B6E03A2381BC8D23AEMAILBOXESnbtt_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:12621 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbZDNTW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 15:22:56 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_57AA7D7FD7A5A24EA0556701B6E03A2381BC8D23AEMAILBOXESnbtt_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hi Ayaz,
 I can consistently replicate the interface hang for an ethernet interface =
which uses nvidia MCP55 mac. The problem occurs whenever the interface rece=
ives a stp packet in promiscuous mode. It happens only when the interface s=
peed/duplex setting is forced to 100/full and the interface in promiscuous =
mode. I can replicate it on Linux2.6.29 kernel.

 I am attaching the packet which produces this error. =20
 To reproduce,=20
* You will need 2 ethernet interfaces tied down to 100/full and connected t=
o each other.=20
* Set the nvidia interface to promiscuous mode (ifconfig $interface promisc=
).=20
* Then run the tcpreplay command with the packet that I have attached. (ex:=
 tcpreplay -i $non_nvidea_interface stpframe.cap)
* After the stp packet is sent, I can no longer send any other packets to t=
he nvidia interface.
* To come out of the interface hang, I need to down/up the interface.

Thanks,
Gurucharan Shetty



=20


--_002_57AA7D7FD7A5A24EA0556701B6E03A2381BC8D23AEMAILBOXESnbtt_
Content-Type: application/cap; name="stpframe.cap"
Content-Description: stpframe.cap
Content-Disposition: attachment; filename="stpframe.cap"; size=100;
	creation-date="Tue, 14 Apr 2009 12:05:22 GMT";
	modification-date="Tue, 14 Apr 2009 12:05:22 GMT"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAW4XbSS4cBAA8AAAAPAAAAAGAwgAAAAARu/+ZJgAmQkID
AAAAAAEACgAHsxoQAAAAAB6AAQARu/+ZAIAmCAAUAAIADwAAAAAAAAAAAA==

--_002_57AA7D7FD7A5A24EA0556701B6E03A2381BC8D23AEMAILBOXESnbtt_--
