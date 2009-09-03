From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Network hangs with 2.6.30.5
Date: Thu, 3 Sep 2009 07:46:10 +0000
Message-ID: <20090903074610.GA6000@ff.dom.local>
References: <pan.2009.09.01.15.32.24.613750@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Clifford Heath <clifford.heath@gmail.com>
To: Holger Hoffstaette <holger.hoffstaette@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:43821 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbZICHqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 03:46:14 -0400
Received: by fxm17 with SMTP id 17so1340665fxm.37
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2009 00:46:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <pan.2009.09.01.15.32.24.613750@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-09-2009 17:32, Holger Hoffstaette wrote:
> On Tue, 01 Sep 2009 16:17:08 +0200, Holger Hoffstaette wrote:
> 
> [network regressions in .30]
> 
>> I do have an older Intel Gbit card identified thusly: 00:0b.0 Ethernet
>> controller: Intel Corporation 82545GM Gigabit Ethernet Controller (rev 04)
>>
>> and enabled all sorts of offloading:
>>
>> $ethtool -k eth0
>> Offload parameters for eth0:
>> rx-checksumming: on
>> tx-checksumming: on
>> scatter-gather: on
>> tcp segmentation offload: on
>> udp fragmentation offload: off
>> generic segmentation offload: on
>>
>> Maybe that is the culprit, as Eric Dumazet suspected in his mail..I will
>> try the latest .30 stable again without that, but in any case something is
>> indeed very broken in there.
> 
> So I just tried .30.5 again. Indeed the offloading seems to play a role:
> with everything enabled I cannot even reliably ssh into the machine (only
> "sometimes"?); however without any offloading things get "a bit better"
> and squid even serves up some pages..for a while. Then it seems to hang,
> swallow requests or not finish them. The tested sites reliably work for
> the Windows client when it bypasses squid, as does DNS (also served from
> the box). It *seems* to affect incoming traffic more than outgoing - e.g.
> mail or news polling seemed to kick off and finish just fine.
> Rebooting back into .29 fixes everything. Last time I tried
> .31rc-something (4 IIRC) it exhibited the same problems.
> 
> I'm open to suggestions and willing to help fix this but need this machine
> for actual work. :/

It seems, you and Clifford, use e1000 so it would be interesting to
find out if it matters. Does your friend with working .30 use another
card? If you can't try with another NIC, we could probably try to
revert most of the driver's changes after .29 (except maybe 3) to
check this driver only.

Clifford, if it still doesn't work for you, could you try 2.6.29?

Jarek P.
