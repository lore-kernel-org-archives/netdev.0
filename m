From: Neil Horman <nhorman@tuxdriver.com>
Subject: Question: igmp behavior on interface change
Date: Wed, 18 Mar 2009 10:03:53 -0400
Message-ID: <20090318140353.GA9771@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andy@greyhouse.net, dlstevens@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51991 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755971AbZCROEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 10:04:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey-
	Was wondering if anyone wanted to chime in on this.  Someone asked me
recently what our behavior should be in response to in interface link state
change in regards to multicast reception.  They claim that if an mc group is
joined, and we issue an igmp join request via, say eth0, and then preform an
ifdown/ifup on that interface, that frames stop getting delivered for that
group.  I'm having this confirmed, but its my guess that in response to the link
flap, the attached router on the other end of the link has unsubscribed from the
group in response to the link state change.

	So my question is, whats the right behavior here?  Reading RFC 3376,
seems to suggest that we need to issue a state-change report as soon as the link
goes back up, but its vague, I could see an argument being made for both the
host and the router to keep their mc group state unchanged and let membership
queries ages the groups out as per normal.

	I was going to look into writing some notification code for igmp to
detect link state chagnes and issue the reports on link up, but I wanted to be
sure there were no counter arguments first.  So any and all thoughts
appreciated.

Thanks!
Neil

