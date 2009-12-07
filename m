From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14737] New: e1000e driver experiences large
   packet losses
Date: Mon, 07 Dec 2009 23:59:05 +0100
Message-ID: <4B1D88B9.7020302@gmail.com>
References: <bug-14737-10286@http.bugzilla.kernel.org/> <20091207131900.19c776ed.akpm@linux-foundation.org> <alpine.WNT.2.00.0912071340480.2420@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "xenoterracide@gmail.com" <xenoterracide@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:65461 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935639AbZLGW7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 17:59:35 -0500
Received: by bwz27 with SMTP id 27so3985200bwz.21
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2009 14:59:41 -0800 (PST)
In-Reply-To: <alpine.WNT.2.00.0912071340480.2420@jbrandeb-mobl2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote, On 12/07/2009 10:53 PM:

> There is nothing in the ethtool -S statistics that I see that indicates 
> anything is wrong, you've gotten no tx timeouts as far as I can tell, have 
> you had any system panics (possibly seeming unrelated to network?)


There are unreplied icmp echos and a lot of tcp retransmits in the
first one (netstat_after.slave4.log.gz):

Ip:
    812 total packets received
    1 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    802 incoming packets delivered
    1048 requests sent out
Icmp:
    488 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 2
        timeout in transit: 289
        echo replies: 197
    677 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 2
IcmpMsg:
        InType0: 197
        InType3: 2
        InType11: 289
        OutType3: 2
        OutType69: 675
Tcp:
    17 active connections openings
    0 passive connection openings
    14 failed connection attempts
    0 connection resets received
    0 connections established
    45 segments received
    49 segments send out
    19 segments retransmited
    0 bad segments received.
    19 resets sent

I analyzed tcpdumps from the router and there were really skipped
icmp echo requests on input. At the same time nothing wrong in the
stats (qdisc, ifconfig, ethtool) of this sending box with e1000e,
and the router's ifconfig (I only didn't see router's netstat).

Anyway, I doubt it's accidental or router to blame if another NIC,
and this e1000e with some boots/kernels(?) can work flawlessly.

Btw, after finding this similarly mysterious story below (with the
same NIC) I wonder if the router model can matter here too, but
maybe I'm wrong.

http://bugzilla.kernel.org/show_bug.cgi?id=11998


Jarek P.
  

> On Mon, 7 Dec 2009, Andrew Morton wrote:
>> (switched to email.  Please respond via emailed reply-to-all, not via the
>> bugzilla web interface).
>>
>> On Sat, 5 Dec 2009 07:02:49 GMT
>> bugzilla-daemon@bugzilla.kernel.org wrote:
>>
>>> http://bugzilla.kernel.org/show_bug.cgi?id=14737
>>>
>>>            Summary: e1000e driver experiences large packet losses
>>>            Product: Drivers
