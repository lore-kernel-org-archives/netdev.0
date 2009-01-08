From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Thu, 8 Jan 2009 08:37:53 -0800
Message-ID: <20090108083753.14670943@extreme>
References: <bug-12327-10286@http.bugzilla.kernel.org/>
	<20081229214101.4c4f5ac1.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi>
	<495BFEAF.6000006@haveacry.com>
	<20090102083402.GA24383@gondor.apana.org.au>
	<4961ECD2.1000502@haveacry.com>
	<20090107041732.GA22041@gondor.apana.org.au>
	<4964B303.4020708@haveacry.com>
	<20090108030745.GA1204@gondor.apana.org.au>
	<4966160A.20001@haveacry.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Speedster <speedster@haveacry.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48885 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbZAHQhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 11:37:55 -0500
In-Reply-To: <4966160A.20001@haveacry.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Jan 2009 00:04:42 +0900
Speedster <speedster@haveacry.com> wrote:

> Herbert Xu wrote:
> > 
> > Can you please take a look at /proc/net/snmp on the host and the
> > guest to see if IP InDiscards is non-zero?
> 
> Both are 0
> 
> > Also now that we know the problem is definitely in the host/guest
> > please take another set of dumps on the interfaces leading to and
> > within the guest to see exactly which path of the system is dropping
> > the reply.
> 
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
> 
> Dean

Maybe there is an issue that GRO receive isn't handling padding
properly?
