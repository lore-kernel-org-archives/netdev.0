From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/3] net: sctp: Add support for MSG_MORE on
 SCTP
Date: Tue, 22 Jul 2014 15:25:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727B3F3@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1727AF02@AcuExch.aculab.com>
 <53CE65B5.3090903@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1727B2A0@AcuExch.aculab.com>
 <53CE7B2A.90104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"Linux Networking Development Mailing List" <netdev@vger.kernel.org>,
	"'linux-sctp@vger.kernel.org'" <linux-sctp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45916 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754122AbaGVP1B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 11:27:01 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25288-05 for <netdev@vger.kernel.org>;
 Tue, 22 Jul 2014 16:26:53 +0100 (BST)
In-Reply-To: <53CE7B2A.90104@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
> On 07/22/2014 09:45 AM, David Laight wrote:
> > From: Vlad Yasevich
> >> On 07/22/2014 04:59 AM, David Laight wrote:
> >>> If MSG_MORE is set then the data chunk will be buffered until either
> >>> a full packet would be generated, or something causes a chunk to be
> >>> sent (eg data without MSG_MORE or a heartbeat).
> >>
> >> heartbeat will not cause a data flush.  Only SACKs do that as they control
> >> congestion and flow.
> >
> > Experimentally heartbeats cause data to be sent.
> > I'd only got one IP address at each end - so don't know what happens to
> > any 'probe' HBs.
> > I frigged my code to set MSG_MORE if the data chunk was over 200 bytes.
> > A single long fragment would be collected by a short one, or by a heartbeat.
> > I did wonder if that was a bug - but it would happen for data delayed by Nagle.
> 
> That sounds kind like a bug.  The end of packet usually causes a flush of the outqueue,
> but any delayed data shouldn't be sent as HB should not cause a data flush.

I think the data is already in the relevant queue, it would have been sent
earlier if there had been a packet with anything in it.
So maybe the HB does get bundled with pending data.

Try applying my patch and doing some simple tests...

	David
