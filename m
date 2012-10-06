From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: replace existing filter creates new filter instead
Date: Fri, 05 Oct 2012 22:43:01 -0400
Message-ID: <1349491381.18710.131.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:58284 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab2JFCnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2012 22:43:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I write most of my tc scripts using replace so I can reload
my configuration as well as create it anew.  However, one particular
filter command is giving me grief.  The below sequence show my listing
of the filters showing and empty list.  Then I replace one and see one.
Then I merely up arrow to execute the exact same replace command and I
then see two filters when I would have expected to see one.  What am I
misunderstanding? Thanks - John

# tc filter show dev bond3 parent 1:0
# tc filter replace dev bond3 parent 1:0 protocol ip prio 1 u32 match u8 0 0 flowid 1:1 action mirred egress redirect dev ifb1
Action 4 device ifb1 ifindex 26
# tc filter show dev bond3 parent 1:0
filter protocol ip pref 1 u32
filter protocol ip pref 1 u32 fh 800: ht divisor 1
filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1
  match 00000000/00000000 at 0
        action order 1: mirred (Egress Redirect to device ifb1) stolen
        index 27 ref 1 bind 1

# tc filter replace dev bond3 parent 1:0 protocol ip prio 1 u32 match u8 0 0 flowid 1:1 action mirred egress redirect dev ifb1
Action 4 device ifb1 ifindex 26
# tc filter show dev bond3 parent 1:0
filter protocol ip pref 1 u32
filter protocol ip pref 1 u32 fh 800: ht divisor 1
filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1
  match 00000000/00000000 at 0
        action order 1: mirred (Egress Redirect to device ifb1) stolen
        index 27 ref 1 bind 1

filter protocol ip pref 1 u32 fh 800::801 order 2049 key ht 800 bkt 0 flowid 1:1
  match 00000000/00000000 at 0
        action order 33: mirred (Egress Redirect to device ifb1) stolen
        index 28 ref 1 bind 1
