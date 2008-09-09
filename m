From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after	some time
Date: Mon, 8 Sep 2008 17:34:00 -0700
Message-ID: <OF604A6380.9CF7D18A-ON882574BF.000171B8-882574BF.00031DB5@us.ibm.com>
References: <20080902150008.GD7289@schleppi.birkenwald.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:43697 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506AbYIIAeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:34:13 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m890Y4bR028117
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 20:34:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m890Y3rd204522
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 18:34:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m890Y39T005193
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 18:34:03 -0600
Received: from d03nm121.boulder.ibm.com (d03nm121.boulder.ibm.com [9.17.195.147])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m890Y3pc005190
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 18:34:03 -0600
In-Reply-To: <20080902150008.GD7289@schleppi.birkenwald.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernhard,
        I looked at this some more and didn't see anything obvious.
The send side doesn't need group membership to send, or anything
special, really. The only thing that comes to mind is that maybe you
have a bogus route installed (since you don't have a bogus interface
flag :-)).
        Can you do an "ip -6 route list" when it's happening?

        Also might be worthwhile to see the entire arg list, so
maybe using the "-s" option to strace to increase it, and we
probably only need sendmsg(), so maybe:

strace -s 1024 -e trace=sendmsg -e verbose=sendmsg ping6 -I eth0 ....

I wanted to see more detail than strace could fit in the default length. 
:-)

                                        +-DLS

