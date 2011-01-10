From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/3] net: add device groups
Date: Mon, 10 Jan 2011 09:00:21 -0500
Message-ID: <1294668021.6063.315.camel@mojatatu>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	 <1294666875.3583.6.camel@jlt3.sipsolutions.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:46441 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab1AJOAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:00:21 -0500
Received: by qwa26 with SMTP id 26so19787472qwa.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 06:00:21 -0800 (PST)
In-Reply-To: <1294666875.3583.6.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-10 at 14:41 +0100, Johannes Berg wrote:

> Can you explain the purpose of this? I'm wondering if it would make
> sense to automatically group all virtual interfaces belonging to a
> single 802.11 device, for instance.

It depends what you want to do with that grouping.
In a nutshell, this greatly reduces the amount of kernel-user netlink
traffic in presence of multi interfaces.
you can do things like:
 
ip link set dev ppp0 group 1
...
...
ip link set dev pppN group 1

ip link ls group 1
ip link set down group 1
ip link set mtu 512 group 1
etc

Although now that i am thinking of it,
I am not sure whether it would be a legit thing to change
the MAC address of a group of devices - we may need to put
some restrictions.

Note: this grouping thing can also be potentially used in
packet policies etc (but i dont want to distract the simple
requirement we have at the moment).

cheers,
jamal 

