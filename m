From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 9/9] net: sctp: sctp_ulpq: do not use char as a struct member
Date: Wed, 17 Apr 2013 17:28:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B71E5@saturn3.aculab.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com> <1366146438-8815-10-git-send-email-dborkman@redhat.com> <20130417154552.GJ5149@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>,
	"Daniel Borkmann" <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57962 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752314Ab3DQQbV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 12:31:21 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 28009-09 for <netdev@vger.kernel.org>;
 Wed, 17 Apr 2013 17:31:19 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130417154552.GJ5149@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  /* A structure to carry information to the ULP (e.g. Sockets API) */
> >  struct sctp_ulpq {
> > -	char pd_mode;
> >  	struct sctp_association *asoc;
> >  	struct sk_buff_head reasm;
> >  	struct sk_buff_head lobby;
> > +	__u8 pd_mode:1;
> >  };
> >
> 
> Can you move the char (or __u8 if you prefer) to right after the reasm meber?  I
> think theres a hole there that you can fill in

If there is a hole after 'reasm' there will also be one after 'lobby'.
In any case it can't be worse than the 7 byte pad after pd_mode
in the existing file.

In the other structure there is a uint32 preceding the three
flag bytes - so unless some other stuff is moved making them
bitfields won't change any sizes at all.

FWIW we do use SCTP (for M3UA).
The code has to be an order of magnitude slower than TCP!
Never mind the difficulty in generating long ethernet frames
(since the data flow means you have to disable nagle).

	David.
