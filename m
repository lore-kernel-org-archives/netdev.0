From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net v2 0/2] mpls: fix route del errors on wrong scope and type
Date: Wed, 27 May 2015 11:37:03 -0700
Message-ID: <1432751825-40804-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35200 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbbE0ShK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:37:10 -0400
Received: by pacwv17 with SMTP id wv17so3951034pac.2
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 11:37:10 -0700 (PDT)
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

v2: split the fix between iproute2 and kernel as suggested by
	Eric Biederman

Roopa Prabhu (2):
  iproute2: mpls: always set type as RTN_UNICAST for route
  mpls: fix mpls route deletes to not check for route scope

 net/mpls/af_mpls.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

-- 
1.7.10.4
