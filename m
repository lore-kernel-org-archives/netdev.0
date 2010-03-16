From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [PATCH net-next-2.6 v6 08/12] net-caif: add CAIF socket implementation
Date: Tue, 16 Mar 2010 14:27:21 +0100
Message-ID: <61D8D34BB13CFE408D154529C120E079033D51A2@eseldmw101.eemea.ericsson.se>
References: <1267445559-1911-1-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-2-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-3-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-4-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-5-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-6-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-7-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-8-git-send-email-sjur.brandeland@stericsson.com> <1267445559-1911-9-git-send-email-sjur.brandeland@stericsson.com> <1268690031.2700.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	"Daniel Martensson" <daniel.martensson@stericsson.com>,
	<kaber@trash.net>, <stefano.babic@babic.homelinux.org>,
	<randy.dunlap@oracle.com>
To: "Marcel Holtmann" <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:44475 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966190Ab0CPN1Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 09:27:24 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1268690031.2700.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Marcel.

Marcel Holtmann wrote:
>> +	/*
>> +	 * The sock->type specifies the socket type to use. The CAIF
>> socket is +	 * a packet stream in the sence that it is packet based.
>> +	 * CAIF trusts the reliability of the link, no resending is
>> implemented. +	 */ +	if (sock->type != SOCK_SEQPACKET)
>> +		return -ESOCKTNOSUPPORT;
> 
> we came to an interesting detail here when testing with a STE modem.
> Why is this SEQPACKET and not a STREAM.

The reason is that CAIF provides different services not just AT,
and some of them are really packet oriented such as Utility links and
Video. It would not be right to provide a stream based solution in this case.

> Especially with the AT
> command channels it is kinda weird that you have an MTU. The AT
> specification doesn't really have any defined behavior when using a
> sequential packet transport. It is more a stream based socket.

Yes I see your point. In order to limit the effort and simplify
caif_socket we ended up implementing only SEQPACKET. 

BR/Sjur
