From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: tcp wifi upload performance and lots of ACKs
Date: Thu, 7 Jun 2012 13:20:19 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F3C@saturn3.aculab.com>
References: <4FD02AFB.7040004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev" <netdev@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>,
	"Daniel Baluta" <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38538 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751652Ab2FGM3g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 08:29:36 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05278-06 for <netdev@vger.kernel.org>;
 Thu,  7 Jun 2012 13:29:31 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <4FD02AFB.7040004@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org] On Behalf Of Ben Greear
> Sent: 07 June 2012 05:16
> To: Daniel Baluta
> Cc: netdev
> Subject: Re: tcp wifi upload performance and lots of ACKs
> 
> On 06/04/2012 12:22 PM, Daniel Baluta wrote:
> > On Mon, Jun 4, 2012 at 9:29 PM, Ben Greear<greearb@candelatech.com>
wrote:
> >> I'm going some TCP performance testing on wifi ->  LAN interface
connections.
> >>   With
> >> UDP, we can get around 250Mbps of payload throughput.  With TCP,
max is
> >> about 80Mbps.
> >>
> >> I think the problem is that there are way too many ACK packets, and
> >> bi-directional
> >> traffic on wifi interfaces really slows things down.  (About 7000
pkts per
> >> second in
> >> upload direction, 2000 pps download.  And the vast majority of the
download
> >> pkts
> >> are 66 byte ACK pkts from what I can tell.)
> 
> > [1] http://marc.info/?l=linux-netdev&m=131983649130350&w=2
> 
> After a bit more playing, I did notice a reliable 5% increase in
> traffic (200Mbps -> 210Mbps) from changing the delack segments
> to 20 from the default of 1.  That is enough to be useful to me,
> and there may be more significant gains to be found...
> I haven't done a full matrix of testing yet.

Does this delaying of acks have a detrimental effect on the
sending end?
I've seen very bad interactions between delayed acks and
(I believe) the 'slow start' code on connections with
one-directional data, Nagle disabled and very low RTT.

What I saw was the sender sending 4 data packets, then
sitting waiting for an ack - in spite of accumulating
several kB of data to send.

Delaying acks further will only make this worse.

	David
