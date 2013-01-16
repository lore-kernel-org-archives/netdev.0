From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [RFC Patch net-next] tcp: add a global sysctl to control TCP delayed ack
Date: Wed, 16 Jan 2013 12:22:43 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7110@saturn3.aculab.com>
References: <1358334345-28980-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Rick Jones" <rick.jones2@hp.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Thomas Graf" <tgraf@suug.ch>
To: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58866 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753784Ab3APMYt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 07:24:49 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 19705-09 for <netdev@vger.kernel.org>;
 Wed, 16 Jan 2013 12:24:42 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1358334345-28980-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> According to previous discussion, it seems there is no
> reasonable heuristics.
> 
> Similar to TCP_QUICK_ACK option, but for people who can't
> modify the source code and still wants to control
> TCP delayed ACK behavior.
> 
> Makes any sense?

A sysctl is a bit of a big hammer, it probably isn't necessary
to disable delayed acks on all connections.

IIRC the related problems I saw were really on the sending
side when Nagle is disabled and it is doing 'slow start'.

Globally disabling on connections that have Nagle disabled
might be a possibility - but it is the Nagle parameter
at the other end that matters.

Perhaps the sending side, after sending 4 small frames immediately,
could send 1 or 2 additional full sized frames in order to
provoke an ack (IIRC an ack is sent if there are 2 full sized
frames of data unacked).

The other problem is that 'slow start' is restarted very
aggressively - whenever there is no unacked data.
If you have a very low latency connection and aren't doing
continuous bulk transfer it is restarted for every short
burst of transmits - effectively after every received ack.
There really ought to have to be a moderate idle time
before 'slow start' is restarted.

	David
