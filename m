From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on 2.6.24?
Date: Mon, 12 Jan 2009 02:18:59 +0300
Message-ID: <20090111231859.GA8309@ioremap.net>
References: <20090111212303.GA8612@outpost.ds9a.nl> <175f5a0f0901111408s7905e5d9l2155b841f1ac054d@mail.gmail.com> <20090111224541.GA10848@outpost.ds9a.nl> <20090111225427.GA7004@ioremap.net> <20090111230824.GB10848@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: bert hubert <bert.hubert@netherlabs.nl>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:49802 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751249AbZAKXTC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jan 2009 18:19:02 -0500
Content-Disposition: inline
In-Reply-To: <20090111230824.GB10848@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 12:08:24AM +0100, bert hubert (bert.hubert@netherlabs.nl) wrote:
> I fully understand. Sometimes I have to talk to stupid devices though. What
> I do find is the TCP_INFO ioctl, which offers this field in struct tcp_info:
> 
>         __u32   tcpi_unacked;
> 
> Which comes from:
> 
> struct tcp_sock {
> ...
>         u32     packets_out;    /* Packets which are "in flight"        */
> ...
> }
> 
> If this becomes 0, perhaps this might tell me everything I sent was acked?

0 means that there are noin-flight packets, which is effectively number
of unacked packets. So if your application waits for this field to
become zero, it will wait for all sent packets to be acked.

-- 
	Evgeniy Polyakov
