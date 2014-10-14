From: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Subject: TCP socket receives strange packet
Date: Tue, 14 Oct 2014 18:09:54 +0400
Message-ID: <543D2EB2.4000009@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020208070708090309040403"
Cc: "Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shelob.oktetlabs.ru ([84.52.89.53]:52147 "EHLO
	shelob.oktetlabs.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbaJNOTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 10:19:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020208070708090309040403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Connected TCP socket receives packet without timestamps option which 
exists in SYN, SYNACK and ACK. It is packet 4 in attached tcpdump output.

tcpdump output description: The host has address 10.208.10.1 (server) 
and the peer host has address 10.208.10.2 (client).

Establishing connection: Timestamps option exists in SYN, SYNACK and ACK 
(packets 1, 2 and 3 in attached file), so accepted socket should receive 
packets only with timestamps option.

Sending packet: the socket receives the packet without timestamps option 
(packet 4 in attached file), i.e. recv() function called on the socket 
receives the data from the packet. The "strange" packet is generated 
using PCAP.

I see this behaviour on 2.6.26 and on 3.14 kernels.

--------------020208070708090309040403
Content-Type: application/octet-stream;
 name="pcap_with_bad_packet"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="pcap_with_bad_packet"

1MOyoQIABAAAAAAAAAAAANwFAAABAAAAKaIzVLqlDgBKAAAASgAAAAAPUwE5fAAPUwE5lAgA
RQAAPHbYQABABppBCtAKAgrQCgFlvWW8lT487wAAAACgAnIQxF4AAAIEBbQEAggKABBKNwAA
AAABAwMHKaIzVNmlDgBKAAAASgAAAAAPUwE5lAAPUwE5fAgARQAAPAAAQABABhEaCtAKAQrQ
CgJlvGW9JBhNSpU+PPCgEnEgKdEAAAIEBbQEAggKABB/SgAQSjcBAwMHKaIzVDamDgBCAAAA
QgAAAAAPUwE5fAAPUwE5lAgARQAANHbZQABABppICtAKAgrQCgFlvWW8lT488CQYTUuAEADl
c4gAAAEBCAoAEEo3ABB/SiqiM1R/GgIAPAAAADwAAAAAD1MBOXwAD1MBOZQIAEUAACkAAAAA
QAZRLQrQCgIK0AoBZb1lvJU+PPAkGE1KUBj//xAeAABnAAAAAAAqojNUnBoCAEIAAABCAAAA
AA9TATmUAA9TATl8CABFAAA0MgFAAEAG3yAK0AoBCtAKAmW8Zb0kGE1LlT488YAQAOMpyQAA
AQEICgAQf3cAEEo3KqIzVKKQAwBCAAAAQgAAAAAPUwE5lAAPUwE5fAgARQAANDICQABABt8f
CtAKAQrQCgJlvGW9JBhNS5U+PPGAEQDjKckAAAEBCAoAEH+OABBKNyqiM1S+kwMAQgAAAEIA
AAAAD1MBOXwAD1MBOZQIAEUAADR22kAAQAaaRwrQCgIK0AoBZb1lvJU+PPAkGE1LgBEA5XNC
AAABAQgKABBKfAAQf0oqojNU3ZMDAE4AAABOAAAAAA9TATmUAA9TATl8CABFAABAMgNAAEAG
3xIK0AoBCtAKAmW8Zb0kGE1MlT488bAQAOMp1QAAAQEICgAQf48AEEp8AQEFCpU+PPCVPjzx
KqIzVJG7CQBCAAAAQgAAAAAPUwE5lAAPUwE5fAgARQAANDIEQABABt8dCtAKAQrQCgJlvGW9
JBhNS5U+PPGAEQDjKckAAAEBCAoAEH/0ABBKfCqiM1T2uwkAQgAAAEIAAAAAD1MBOXwAD1MB
OZQIAEUAADRHFUAAQAbKDArQCgIK0AoBZb1lvJU+PPEkGE1MgBAA5XIyAAABAQgKABBK4QAQ
f/Q=
--------------020208070708090309040403--
