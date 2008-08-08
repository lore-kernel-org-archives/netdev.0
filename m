From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]ip: Allow for easier debug of buggy devices that dont
	send their names
Date: Fri, 08 Aug 2008 10:06:17 -0400
Message-ID: <1218204378.4688.65.camel@localhost>
References: <1218204048.4688.62.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-GEf9/X9TJ7iScBGUa3m6"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:16904 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbYHHOGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 10:06:44 -0400
Received: by yx-out-2324.google.com with SMTP id 8so242865yxm.1
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 07:06:43 -0700 (PDT)
In-Reply-To: <1218204048.4688.62.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GEf9/X9TJ7iScBGUa3m6
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

patch attached this time..

On Fri, 2008-08-08 at 10:01 -0400, jamal wrote:
> wireless drivers using wext is a prime example if you need a test case.
> 
> cheers,
> jamal

--=-GEf9/X9TJ7iScBGUa3m6
Content-Disposition: attachment; filename=iprl1
Content-Type: text/plain; name=iprl1; charset=us-ascii
Content-Transfer-Encoding: 7bit

ip: Allow for easier debug of buggy devices that dont send their names

With the old message couldnt tell which device had the bug.
This patch provides at least an ifindex to narrow it down.
Theres also no point in bailing out because of one bug; we
allow it to go on so we could dump as much info as we can

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 741059fd8ae6c07794d56c56395354f95543f648
tree 0a0e8e4508a2d08c4bd450fcb1c74142fbd64837
parent 488f1c77fec1b283ef5237943d397786f90d2fe5
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 08 Aug 2008 09:57:49 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Fri, 08 Aug 2008 09:57:49 -0400

 ip/ipaddress.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 373312f..a5af36d 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -210,8 +210,7 @@ int print_linkinfo(const struct sockaddr_nl *who,
 
 	parse_rtattr(tb, IFLA_MAX, IFLA_RTA(ifi), len);
 	if (tb[IFLA_IFNAME] == NULL) {
-		fprintf(stderr, "BUG: nil ifname\n");
-		return -1;
+		fprintf(stderr, "BUG: device with ifindex %d has nil ifname\n", ifi->ifi_index);
 	}
 	if (filter.label &&
 	    (!filter.family || filter.family == AF_PACKET) &&

--=-GEf9/X9TJ7iScBGUa3m6--

