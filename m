From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net v3 0/2] mpls: fix route del errors on wrong scope and type
Date: Mon,  1 Jun 2015 23:29:25 -0700
Message-ID: <1433226567-23302-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34940 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbbFBG3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 02:29:33 -0400
Received: by padjw17 with SMTP id jw17so54237012pad.2
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 23:29:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch fixes incorrect -EINVAL errors due to invalid
scope and type during mpls route deletes.

$ip -f mpls route add 100 as 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route show
100 as to 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1
RTNETLINK answers: Invalid argument

$ip -f mpls route del 100
RTNETLINK answers: Invalid argument

After patch:

$ip -f mpls route show
100 as to 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route del 100 as 200 via inet 10.1.1.2 dev swp1

$ip -f mpls route show

Reported-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Vivek Venkataraman <vivek@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---

v2: split the fix between iproute2 and kernel as suggested by
	Eric Biederman

v3: fix if condition indent

Roopa Prabhu (2):
  iproute2: mpls: always set type as RTN_UNICAST for route
  mpls: fix mpls route deletes to not check for route scope

 net/mpls/af_mpls.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

-- 
1.7.10.4
