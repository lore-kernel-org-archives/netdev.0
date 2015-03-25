From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] lib utils: fix family during af_bit_len
 calculation
Date: Wed, 25 Mar 2015 15:31:47 +0200
Message-ID: <20150325133147.GA946@angus-think.wlc.globallogic.com>
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
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33325 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbbCYNnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 09:43:47 -0400
Received: by lbcmq2 with SMTP id mq2so17860285lbc.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 06:43:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427290352.25985.111.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 25, 2015 at 06:32:32AM -0700, Eric Dumazet wrote:
> On Tue, 2015-03-24 at 15:05 -0700, Stephen Hemminger wrote:
> > On Tue, 17 Mar 2015 19:18:28 -0700
> > roopa@cumulusnetworks.com wrote:
> > 
> > > From: Roopa Prabhu <roopa@cumulusnetworks.com>
> > > 
> > > commit f3a2ddc124e0 ("lib utils: Use helpers to get AF bit/byte len")
> > > used a wrong family or family of zero in the default case
> > > during af_bit_len calculation causing ip route commands to
> > > fail with below error
> > > 
> > > Error: an inet prefix is expected rather than "10.0.2.14/24".
> > > 
> > > Reported-by: Sven-Haegar Koch <haegar@sdinet.de>
> > > Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> > 
> > Applied, thanks everybody
> 
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

I will try to look at these issues today later.

Regards,
