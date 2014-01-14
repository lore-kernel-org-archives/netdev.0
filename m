From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 0/5] xfrm: Add ESN support for AH
Date: Tue, 14 Jan 2014 09:39:07 +0800
Message-ID: <1389663552-29638-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64638 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaANBjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:39:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is initial Extended Sequence Number support for AH based on IPv4/6.
The rationale is totally by the RFC 4302, which states:

3.3.3.2.2.  Implicit Packet Padding and ESN

   If the ESN option is elected for an SA, then the high-order 32 bits
   of the ESN must be included in the ICV computation.  For purposes of
   ICV computation, these bits are appended (implicitly) immediately
   after the end of the payload, and before any implicit packet padding.

So we attach the high-order 32bits as a scatterlist right after the packet
payload to compute ICV value. 

Test:
I add a knob in iproute2/ip/xfrm_state.c to enable esn when setting SA,
which make it possible to test with-esn and without-esn scenarios, both
cases works ok with ping using packetsize(-s) from default to 32768. 

v2:
  - Patch3/5 and Patch4/5 add IPv6 part as requested by Steffen.
  - Patch5/5 restrict ESN feature only to ESP and AH.
v3:
  - Fix double parens spotted by Sergei, and thanks for reporting.

Fan Du (5):
  {IPv4,xfrm} Add ESN support for AH egress part
  {IPv4,xfrm} Add ESN support for AH ingress part
  {IPv6,xfrm} Add ESN support for AH egress part
  {IPv6,xfrm} Add ESN support for AH ingress part
  xfrm: Don't prohibit AH from using ESN feature

 net/ipv4/ah4.c       |   50 +++++++++++++++++++++++++++++++++++++++++-------
 net/ipv6/ah6.c       |   52 +++++++++++++++++++++++++++++++++++++++++++-------
 net/xfrm/xfrm_user.c |    3 ++-
 3 files changed, 90 insertions(+), 15 deletions(-)

-- 
1.7.9.5
