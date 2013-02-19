From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Tue, 19 Feb 2013 14:38:04 -0800
Message-ID: <1361313484.19353.172.camel@edumazet-glaptop>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
	   <511E8760.9070703@candelatech.com>
	  <1360955900.19353.22.camel@edumazet-glaptop>
	  <511E8C3D.5070603@candelatech.com>
	 <1360956930.19353.24.camel@edumazet-glaptop>
	 <5123FB32.7050101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	kaber@trash.net, ataschner@suse.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:62062 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933223Ab3BSWiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 17:38:07 -0500
Received: by mail-da0-f53.google.com with SMTP id g27so86294dan.12
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 14:38:06 -0800 (PST)
In-Reply-To: <5123FB32.7050101@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-19 at 14:22 -0800, Ben Greear wrote:
> On 02/15/2013 11:35 AM, Eric Dumazet wrote:
> > On Fri, 2013-02-15 at 11:27 -0800, Ben Greear wrote:
> >
> >> For some reason I was thinking this wasn't fully fixed for IPv4, but
> >> maybe it is..the bug in our internal tracker only mentions IPv6
> >> as having issues...
> >>
> >> We'll do some testing on IPv4 sometime soon to make sure, and can test
> >> IPv6 patches as well...
> >
> > This worries me a bit, as I wrote this patch because you reported the
> > issue.
> 
> We just did some testing on this on the 3.7.6+ kernel.  IPv4 multicast to
> mac-vlans works OK with large packets if there is a single multicast receiver,
> but does NOT work if there are multiple multicast receivers (ie, several
> mac-vlans with an mcast receive bound to each mvlan).
> 
> Our setup also involves routing rules and send-to-self rules,
> with sender on the same machine, but I'm not sure that matters
> too much or not.

It might matter, because before commit 6d1ccff627806829c (net: reset mac
header in dev_start_xmit() ), we were accessing wrong ethernet header in
macvlan_broadcast() in the send-to-self path

struct ethhdr *eth = eth_hdr(skb);

was simply wrong.

You should try net-next and if it still fails, maybe share your test
programs.
