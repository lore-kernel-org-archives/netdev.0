From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [RFC iproute2] tc: Show classes in tree view
Date: Fri, 19 Dec 2014 18:46:20 +0200
Message-ID: <20141219164620.GA9364@angus-think>
References: <1418989381-6492-1-git-send-email-vadim4j@gmail.com>
 <CAHA+R7P0eZzEgx+Oq-X8eqs7NFFLon4HKa+UUgxDpdaM5e0X+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:48604 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751156AbaLSQ4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 11:56:24 -0500
Received: by mail-la0-f50.google.com with SMTP id pn19so1165258lab.23
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 08:56:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAHA+R7P0eZzEgx+Oq-X8eqs7NFFLon4HKa+UUgxDpdaM5e0X+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2014 at 08:44:30AM -0800, Cong Wang wrote:
> On Fri, Dec 19, 2014 at 3:43 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> > From: Vadim Kochan <vadim4j@gmail.com>
> >
> > Added new '-t[ree]' which shows classes dependency
> > in the tree view.
> >
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> 
> A sample output would convince people more easily.

Yeah, good point:

# tc/tc -t class show dev tap0
+---1:2(htb) rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b 
|   +---1:40(htb) prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b 
|   +---1:50(htb) prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b 
|   +---1:60(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
|   
+---1:1(htb) rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b 
    +---1:10(htb) prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b 
    +---1:20(htb) prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b 
    +---1:30(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 

# tc/tc -t -s class show dev tap0
+---1:2(htb) rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b 
|   |        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
|   |        rate 0bit 0pps backlog 0b 0p requeues 0 
|   |
|   +---1:40(htb) prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b 
|   |             Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
|   |             rate 0bit 0pps backlog 0b 0p requeues 0 
|   |    
|   +---1:50(htb) prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b 
|   |             Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
|   |             rate 0bit 0pps backlog 0b 0p requeues 0 
|   |    
|   +---1:60(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
|                 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
|                 rate 0bit 0pps backlog 0b 0p requeues 0 
|   
+---1:1(htb) rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b 
    |        Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
    |        rate 0bit 0pps backlog 0b 0p requeues 0 
    |
    +---1:10(htb) prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b 
    |             Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
    |             rate 0bit 0pps backlog 0b 0p requeues 0 
    |    
    +---1:20(htb) prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b 
    |             Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
    |             rate 0bit 0pps backlog 0b 0p requeues 0 
    |    
    +---1:30(htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
                  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
                  rate 0bit 0pps backlog 0b 0p requeues 0 
