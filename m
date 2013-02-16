From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Sat, 16 Feb 2013 09:48:58 +0100
Message-ID: <20130216084858.GA13340@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
 <511E8760.9070703@candelatech.com>
 <1360955900.19353.22.camel@edumazet-glaptop>
 <511E8C3D.5070603@candelatech.com>
 <1360956930.19353.24.camel@edumazet-glaptop>
 <511EEE14.8050902@redhat.com>
 <511EF59A.4090103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:45016 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413Ab3BPIwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 03:52:13 -0500
Content-Disposition: inline
In-Reply-To: <511EF59A.4090103@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 09:57:30PM -0500, Vlad Yasevich wrote:
> On 02/15/2013 09:25 PM, Vlad Yasevich wrote:
> >On 02/15/2013 02:35 PM, Eric Dumazet wrote:
> >>On Fri, 2013-02-15 at 11:27 -0800, Ben Greear wrote:
> >>
> >>>For some reason I was thinking this wasn't fully fixed for IPv4, but
> >>>maybe it is..the bug in our internal tracker only mentions IPv6
> >>>as having issues...
> >>>
> >>>We'll do some testing on IPv4 sometime soon to make sure, and can test
> >>>IPv6 patches as well...
> >>
> >>This worries me a bit, as I wrote this patch because you reported the
> >>issue.
> >>
> >>commit bc416d9768aa9a2e46eb11354a9c58399dafeb01
> >>Author: Eric Dumazet <eric.dumazet@gmail.com>
> >>Date:   Thu Oct 6 10:28:31 2011 +0000
> >>
> >>     macvlan: handle fragmented multicast frames
> >>
> >>     Fragmented multicast frames are delivered to a single macvlan port,
> >>     because ip defrag logic considers other samples are redundant.
> >>
> >>     Implement a defrag step before trying to send the multicast frame.
> >>
> >>     Reported-by: Ben Greear <greearb@candelatech.com>
> >>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >>     Signed-off-by: David S. Miller <davem@davemloft.net>
> >>
> >>

Here's the correct link to the test program:
git://github.com/Hugne/udp_mc.git

My tree was just a few days old so it did contain this patch.
Anyway, I retested with latest now and can confirm that it's still there.

I set up some ip6tables logging, and it is clear that all interfaces are 
receiving all fragments, but fail to reassemble them.
netstat -6 -s |grep reass
    8880 reassemblies required
    490 packets reassembled ok
    2898 packet reassembles failed

ip6tables -N LOGME
ip6tables -A LOGME -j LOG
ip6tables -A INPUT -d ff02::/16 -i macvlan0 -j LOGME
ip6tables -A INPUT -d ff02::/16 -i eth0 -j LOGME
ip6tables -A LOGME -j ACCEPT

//E
