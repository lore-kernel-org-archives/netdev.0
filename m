From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 14241] New: Promiscuous mode on network slows the network
 down
Date: Mon, 28 Sep 2009 09:52:03 -0700
Message-ID: <20090928095203.66b85207@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48109 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751992AbZI1QwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2009 12:52:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 26 Sep 2009 23:34:40 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 14241] New: Promiscuous mode on network slows the network down


http://bugzilla.kernel.org/show_bug.cgi?id=14241

           Summary: Promiscuous mode on network slows the network down
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.31
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: mwahal@gmail.com
        Regression: No


Hi,

I have been running 2.6.22.14 kernel for about 2+ years on a pentium D 925, 1GB
DDR2 system. I have a realtek 8169 gigabit onboard network controller on a
ubuntu distribution. I wanted to try kvm but it didn't run because the
kvm-intel module of 2.6.22 kernel is way too old. So, I upgraded to 2.6.28 (and
later to 2.6.31 to eliminate 2.6.28 issues) to try that kernel. The kvm did
work with 2.6.28. I had to put the ethernet in bridge mode so that the kvm
guest OS gets the same IP address from my subnet. As a side effect when putting
in bridge mode, the ethernet interface also enters promiscuous mode. I made
changes in /etc/network/interface file as per ubuntu kvm wiki page to add a
bridge interface and add the eth0 to the bridge port.

Anyway, I noticed that certain network related tasks were taking too long. I
stream video my server using UPnP to my UPnP client. The UPnP client had
trouble streaming over a gigabit network inside my home. I was watching a x264
720p movie yesterday and it was freezing on almost each frame. This is all with
2.6.28 (and later upgraded to 2.6.31 latest kernel). If I downgrade back to
2.6.22 kernel, I dont have any issues streaming even a 20Mbps movie.

I've a 6Mbps DSL line at home. I run some scripts during the day to get stocks
quotes from yahoo. That involves about issues 100 or so wget requests. On a
2.6.22 kernel, that takes about 2-3 mins to complete. On a 2.6.31 kernel it
takes about 45-50 mins.

Since I didnt change the /etc/network/interfaces file , so when 2.6.22 loads,
the ethernet still enters into promiscuous mode. I can run iftop and see that
its watching other traffic on my network.

So, my conclusion is that there is something drastically change in the ethernet
driver when it runs in promiscuous mode between 2.6.22 and 2.6.28 (or 31) which
is making it run excruciatingly slow. I'm open to all suggestions for making
any changes to my system. I'm willing to offer whatever information is needed
from my system if someone is willing to take a look at it. I do need kvm but
not the expense of a sloooow network.

Thanks for reading so far.

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
