From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv5 net-next 0/8] pktgen IPsec support
Date: Fri, 3 Jan 2014 11:18:26 +0800
Message-ID: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47818 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbaACDSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:18:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Dave

Current pktgen IPsec supports only transport/ESP combinnation,
This patchset enables user to do almost any IPsec transformation,
both transport/tunnel mode, and AH/ESP/IPcomp type.

Below configuration has been tested, and using Wireshark could decrypt
out plain text in good formation without any checksum/auth errors:

Mode/TYPE   AH  ESP 
Transport   x   x   
Tunnel      x   x   

ChangeLog
v2:
  Rebase patchset against newest net-next.
  Patch1: Remove adding rebundant empty line spotted by Sergei.
  Patch2: Use only one dst pointing into itself to save space.

v3:
  Align with David's requirement, that for user depends on orignal
  a553e4a6317b2cfc7659542c10fe43184ffe53da ("IPSEC support") from
  Jamal, their testbed configuration will not need to be changed. 

  Add Patch2/7, Patch3/7 for statistic counting, as well as fixing
  lock usage issue. 

v4:
  Add Patch8/8 to document IPsec usage in pktgen, both for orignal
  implementation and this enhancement, adviced by Jamal. And comment
  format fix spoted by Sergei.

v5:
  Rebase this patchset on top of xfrm locks namespace support.

Fan Du (8):
  {pktgen, xfrm} Correct xfrm state lock usage when transforming
  {pktgen, xfrm} Add statistics counting when transforming
  {pktgen, xfrm} Correct xfrm_state_lock usage in xfrm_stateonly_find
  {pktgen, xfrm} Using "pgset spi xxx" to spedifiy SA for a given flow
  {pktgen, xfrm} Construct skb dst for tunnel mode transformation
  {pktgen, xfrm} Introduce xfrm_state_lookup_byspi for pktgen
  {pktgen, xfrm} Show spi value properly when ipsec turned on
  {pktgen, xfrm} Document IPsec usage in pktgen.txt

 Documentation/networking/pktgen.txt |   15 +++++++
 include/net/xfrm.h                  |    2 +
 net/core/pktgen.c                   |   80 +++++++++++++++++++++++++++++------
 net/xfrm/xfrm_state.c               |   26 +++++++++++-
 4 files changed, 107 insertions(+), 16 deletions(-)

-- 
1.7.9.5
