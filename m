From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC 1/2] netmap: infrastructure (in staging)
Date: Sat, 20 Apr 2013 13:31:02 +0200
Message-ID: <51727C76.6010501@redhat.com>
References: <20130419120651.4e646976@nehalam.linuxnetplumber.net> <20130419194537.GA1633@kroah.com> <20130419.155859.1092595631804890737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, stephen@networkplumber.org,
	netdev@vger.kernel.org, Eric Leblond <eric@regit.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754834Ab3DTLbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 07:31:14 -0400
In-Reply-To: <20130419.155859.1092595631804890737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2013 09:58 PM, David Miller wrote:
> From: Greg KH <gregkh@linuxfoundation.org>
> Date: Fri, 19 Apr 2013 12:45:37 -0700
>
>> On Fri, Apr 19, 2013 at 12:06:51PM -0700, Stephen Hemminger wrote:
>>> Netmap is a framework for packet generation and capture from user
>>> space. It allows for efficient packet handling (up to line rate on
>>> 10Gb) with minimum system load.  For more info see:
>>> 	http://info.iet.unipi.it/~luigi/netmap/
>
> So are you saying that people can't get line rate today?
>
> Even the the suricata folks are doing deep packet inspection at line
> rate using AF_PACKET fanouts just fine.  That means they aren't just
> grabbing packets, they are actually processing them and making
> stateful decisions based upon the packet's contents.
>
> That means that capture is cheap enough already that they have all
> the compute left over that they need.
>
> The existing mechanisms also have the huge advantage that they are
> already implemented, require zero driver specific changes, and are
> already starting to be deployed to end users.

+1, and if so, then I'm actually rather for further improving/optimizing/..
AF_PACKET. Btw., Eric had a blog post from 2012 about this topic (and
maybe TPACKET_V3 could even further improve perf. over TPACKET_V2 on this):

   https://home.regit.org/2012/07/suricata-to-10gbps-and-beyond/

Also, I just looked over Netmap's Usenix paper from 2012, where they compare
netmap against pktgen, and while they state the version of the FreeBSD kernel
where they did the evaluation on, they just don't even mention the Linux'
kernel version, their Linux kernel setup etc. Not even mentioning a comparison
of PF_PACKET+fanout (similarly as the PF_RING project seems to avoid this
comparison and only presents perf numbers where they just count packets !).
Also, I've seen other papers published in 2012 on this topic, where they
compare performance with a 2.6.2x kernel, hm, quite sad actually.
