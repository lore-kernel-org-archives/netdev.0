From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 6409] New: llc_rcv doesn't handle receives
 using nr_frags and frags[]
Date: Wed, 19 Apr 2006 11:38:06 -0700
Message-ID: <20060419113806.29ba0d23.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:19176 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751085AbWDSSjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2006 14:39:08 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Wed, 19 Apr 2006 11:32:18 -0700
From: bugme-daemon@bugzilla.kernel.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 6409] New: llc_rcv doesn't handle receives using nr_frags and frags[]


http://bugzilla.kernel.org/show_bug.cgi?id=6409

           Summary: llc_rcv doesn't handle receives using nr_frags and
                    frags[]
    Kernel Version: 2.6.16
            Status: NEW
          Severity: normal
             Owner: acme@conectiva.com.br
         Submitter: jesse.brandeburg@intel.com


Most recent kernel where this bug did not occur:
Distribution: n/a
Hardware Environment: i686
Software Environment: n/a
Problem Description:
after hitting a *very hard to repro* BUG in a distro kernel I did some code
inspection that seems to show that llc_rcv does not handle receive packets using 
skb->data *and* skb_shinfo(skb)->frags[]/nr_frags

Steps to reproduce:
Apparently receiving some netware (802_2) traffic when using one of the
PCI-Express e1000 adapters with packet splitting enabled.  Even if the packet is
not split a large frame will use skb->data and ->frags[]

Analysis:
llc_rcv 
  does a skb_clone inside skb_share_check
llc_fixup_skb
skb_trim
__skb_trim
___pskb_trim(x,x,0) <-- realloc set to 0
___pskb_trim BUG on !realloc inside skb_cloned check

I'll attach the trace from the vendor kernel, I believe the problem is still
relevant to 2.6.16.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
