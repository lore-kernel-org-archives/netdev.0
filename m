From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP stack bug related to F-RTO?
Date: Fri, 25 Sep 2009 16:09:38 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0909251556130.13543@wel-95.cs.helsinki.fi>
References: <427999.33681.qm@web63406.mail.re1.yahoo.com> <2c0942db0909241639vafd348eia19436d18b182d60@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-938466288-1253883977=:13543"
Cc: Joe Cao <caoco2002@yahoo.com>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, jcaoco2002@yahoo.com
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60281 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbZIYNJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 09:09:35 -0400
In-Reply-To: <2c0942db0909241639vafd348eia19436d18b182d60@mail.gmail.com>
Content-ID: <alpine.DEB.2.00.0909251607420.13543@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-938466288-1253883977=:13543
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0909251607421.13543@wel-95.cs.helsinki.fi>

On Thu, 24 Sep 2009, Ray Lee wrote:

> [adding netdev cc:]
> 
> On Thu, Sep 24, 2009 at 10:43 AM, Joe Cao <caoco2002@yahoo.com> wrote:
> >
> > Hello,
> >
> > I have found the following behavior with different versions of linux 
> > kernel. The attached pcap trace is collected with server 
> > (192.168.0.13) running 2.6.24 and shows the problem. Basically the 
> > behavior is like this: 
> >
> > 1. The client opens up a big window,
> > 2. the server sends 19 packets in a row (pkt #14- #32 in the trace), but all of them are dropped due to some congestion.
> > 3. The server hits RTO and retransmits pkt #14 in #33
> > 4. The client immediately acks #33 (=#14), and the server (seems like to enter F-RTO) expends the window and sends *NEW* pkt #35 & #36.=A0 Timeoute is doubled to 2*RTO; The client immediately sends two Dup-ack to #35 and #36.
> > 5. after 2*RTO, pkt #15 is retransmitted in #39.
> > 6. The client immediately acks #39 (=#15) in #40, and the server continues to expand the window and sends two *NEW* pkt #41 & #42. Now the timeoute is doubled to 4 *RTO.
> > 8. After 4*RTO timeout, #16 is retransmitted.
> > 9....
> > 10. The above steps repeats for retransmitting pkt #16-#32 and each time the timeout is doubled.
> > 11. It takes a long long time to retransmit all the lost packets and before that is done, the client sends a RST because of timeout.
> >
> > The above behavior looks like F-RTO is in effect.  And there seems to 
> > be a bug in the TCP's congestion control and retransmission algorithm. 
> > Why doesn't the TCP on server (running 2.6.24) enter the slow start? 
> > Why should the server take that long to recover from a short period 
> > of packet loss?
> >
> > Has anyone else noticed similar problem before?  If my analysis was 
> > wrong, can anyone gives me some pointers to what's really wrong and 
> > how to fix it?

Yes, 2.6.24 is an obsoleted version with known wrongs in FRTO 
implementation. Fixes never when to 2.6.24 stable series as it was 
_already_ obsoleted when the problems where reported and found. The 
correct fixes may be found from 2.6.25.7 (.7 iirc) and are included from 
2.6.26 onward too.

Just in case you happen to run ubuntu based kernel from that era (of 
course you should be reporting the bug here then...), a word of warning: 
it seemed nearly impossible for them to get a simple thing like that 
fixed, I haven't been looking if they'd eventually come to some sensible 
conclusion in that matter or is it still unresolved (or e.g., closed 
without real resolution).

-- 
 i.
--8323329-938466288-1253883977=:13543--
