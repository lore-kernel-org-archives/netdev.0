From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 16:09:00 -0500
Message-ID: <20160129210900.GD17127@oracle.com>
References: <20160129180651.GA17127@oracle.com>
 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
 <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, mwdalton@google.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28547 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbcA2VJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:09:09 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/29/16 13:00), Tom Herbert wrote:
> Doesn't every IP/VXLAN packet contains unaligned headers? Why don't
> those create alignment issues (like when stack looks at addresses)?

They do.

http://comments.gmane.org/gmane.linux.network/370672

some of it was fixed in https://lkml.org/lkml/2015/7/20/63.
There's still some NET_IP_ALIGN missing. IIRC, I was seeing
this for mldv3, but the fix has to be done carefully, by
someone who knows how to fully regression test it.

I dont know if other tunneling methods manage to get the 
NET_IP_ALIGN correct in every case. 

Also, while sparc complains about unaligned access
in most cases, some sins may pass under the radar, and other
platforms dont even generate traps, so it's easy to not know
that there's a problem, a lot of the time.

--Sowmini
