From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 2/4] datagram: mem_scheudle functions
Date: Tue, 18 Dec 2007 12:02:15 -0500
Message-ID: <4767FD17.5020603@redhat.com>
References: <474DB80E.5070403@redhat.com> <474DB90B.9090107@redhat.com> <20071201120946.GA14368@gondor.apana.org.au> <47549B05.5090507@redhat.com> <20071215144540.GA29337@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51835 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756813AbXLRREg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 12:04:36 -0500
In-Reply-To: <20071215144540.GA29337@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I really apologize for not replying to this mail sooner.

Herbert Xu wrote:
> On Mon, Dec 03, 2007 at 07:10:45PM -0500, Hideo AOKI wrote:
>> Because we have to call wmem_schedule function in ip_append_data()
>> which is used by several protocols both stream and datagram.
>> I just thought adding the sk_wmem_schedule() was only way to call
>> proper function from ip_append_data().
> 
> ip_append_data can't possibly work for stream protocols.  So
> which stream protocol is calling it?

I think TCP could call ip_append_data(). Here is possible call graph.

tcp_v4_rcv()
  -> tcp_v4_timewait_ack()
       -> tcp_v4_send_ack()
            -> ip_send_reply()
                 -> *ip_append_data()*

tcp_v4_reqsk_send_ack()
  -> tcp_v4_send_ack()
       -> ip_send_reply()
            -> *ip_append_data()*

tcp_v4_do_rcv()
  -> tcp_v4_send_reset()
       -> ip_send_reply()
            -> *ip_append_data()*


Regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
