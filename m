From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] lib utils: fix family during af_bit_len
 calculation
Date: Wed, 25 Mar 2015 18:13:49 +0200
Message-ID: <20150325161349.GA21340@angus-think.wlc.globallogic.com>
References: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
 <20150324150500.6159e407@urahara>
 <1427290352.25985.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	vadim4j@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:34305 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbbCYQZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 12:25:44 -0400
Received: by lagg8 with SMTP id g8so24272334lag.1
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 09:25:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427290352.25985.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> okay... but... still not good.
> 
> Could someone add some basic regression tests on ss command ?
> 
> Vadim, can you take a look at this problem for example ?
> 
> root@edumazet-glaptop2:/usr/src/iproute2# ss --version ; ss -t dst 1.2.3.4
> ss utility, iproute2-ss131122
> State      Recv-Q Send-Q                                                             Local Address:Port                                                                 Peer Address:Port   
> 
> (This was the expected result, and an old ss command is working)
> 
> But with current git tree we now have :
> 
> root@edumazet-glaptop2:/usr/src/iproute2# misc/ss --version ; misc/ss -t dst 1.2.3.4 | head -4
> ss utility, iproute2-ss150210
> State      Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
> ESTAB      0      0      172.29.161.170:37914                74.125.201.138:https                
> ESTAB      0      0      172.29.161.170:60388                74.125.69.189:https                
> ESTAB      0      0      172.29.161.170:42870                74.125.69.188:5228                 
> 

I reproduced this once, but after not any more, I even tried to setup
tcp servers with same address but with no luck, would you please dump
stats into file by -D option and send it, in case if you will catch the
issue ?

> Meaning filter does not work anymore.
> 
> A second problem I noticed are these, although they are not new.
> 
> root@edumazet-glaptop2:/usr/src/iproute2# misc/ss -ta dst ::1
> Error: an inet prefix is expected rather than ":".
> Cannot parse dst/src address.
> 
> root@edumazet-glaptop2:/usr/src/iproute2# misc/ss -ta dst ::ffff:1.2.3.4
> Error: "1.2.3.4" does not look like a port.
> Cannot parse dst/src address.
> 
> 
> Thanks so much guys.
> 
> 
