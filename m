From: John Dykstra <jdykstra72@gmail.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
	2.6.27
Date: Fri, 09 Jan 2009 00:30:30 +0000
Message-ID: <1231461030.11674.101.camel@Maple>
References: <bug-12327-10286@http.bugzilla.kernel.org/>
	 <20081229214101.4c4f5ac1.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi>
	 <495BFEAF.6000006@haveacry.com>
	 <20090102083402.GA24383@gondor.apana.org.au>
	 <4961ECD2.1000502@haveacry.com>
	 <20090107041732.GA22041@gondor.apana.org.au>
	 <4964B303.4020708@haveacry.com> <20090108030745.GA1204@gondor.apana.org.au>
	 <4966160A.20001@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:14220 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923AbZAIAad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 19:30:33 -0500
Received: by rv-out-0506.google.com with SMTP id k40so8655982rvb.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 16:30:32 -0800 (PST)
In-Reply-To: <4966160A.20001@haveacry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-09 at 00:04 +0900, Speedster wrote:

> Attached (all are the exact same attempted connection), and reveal some 
> interesting information.
> 
> The path the inbound traffic should take is
> 1. vlan50 (host)
> 2. tap interface vnet3 (host) / eth0 (guest)
> 3. ppp0 (guest)
> 
> It looks as though when it is sent out the tap interface the payload 
> length is incorrect in the PPPoE section of the frame. When it arrives 
> via vlan50 it appears fine. Or at least that's what wireshark highlights 
> for me :)

The length field in the PPPoE header doesn't change.  

The packet arrives from the ISP with its PPPoE header length field
showing two extra bytes past the IP payload.  The bridge or something
close to it trims those two bytes from the sk_buff, leaving a packet
whose PPPoE header is wrong, but whose upper headers make sense.  The
PPPoE driver in the virtual machine then drops the packet.

I haven't unscrambled where the drop occurs in the PPPoE driver, but
that's presumably what changed in 2.6.27.  It seems to me that the drop
is proper.  What's wrong is trimming the sk_buff to match the IP header
while ignoring the L2 header, and that's apparently been that way for a
while (if I understand what the reporter is running where).

Or have I screwed up my first posting to netdev?

  --  John


