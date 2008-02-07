From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Problem receiving multicast/promiscuous-mode with kernel.2.6.24
Date: Thu, 7 Feb 2008 08:09:03 -0800
Message-ID: <OF1A029B6E.330C7FB9-ON882573E8.0057AE9D-882573E8.0058B74B@us.ibm.com>
References: <BA41E8A07B73A041948C2E3A4EF6239D062F0B@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: "Reither Robert" <Robert.Reither@av-digital.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:33830 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754240AbYBGQJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 11:09:27 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m17F5b8v023761
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 10:05:37 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m17G9AgW181096
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 09:09:14 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m17G96rO010332
	for <netdev@vger.kernel.org>; Thu, 7 Feb 2008 09:09:07 -0700
In-Reply-To: <BA41E8A07B73A041948C2E3A4EF6239D062F0B@av-digital-exch.avdigital.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You need to join the multicast group on the interface you want
to receive it. If you're setting both imr_address and imr_index
to 0, you haven't specified an interface.

Instead of setting imr_ifindex to 0, try setting it like this:

imr.imr_ifindex = if_nametoindex("eth0");

 (or whatever interface you need).

You can verify that you've joined the group on the correct
interface with "netstat -g", also. Make sure that the interface
field is correct for the group you want.

And because I can't resist mentioning it, "inet_aton" is deprecated--
suggest inet_pton() with appropriate arguments and return value
checking instead.

There was a bug fix where the sense of promiscuous mode was
backwards for multicasting, which is probably why it was accidently
(and incorrectly) working in earlier kernels.

If that doesn't do it for you, let me know; better if you can post the
full code (or even better, the smallest subset that demonstrates the
problem).

                                                +-DLS

