From: Patrick McHardy <kaber@trash.net>
Subject: Re: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 18:21:09 +0100
Message-ID: <4B13FF05.5060005@trash.net>
References: <alpine.DEB.2.00.0911301104520.16713@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55744 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbZK3RVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:21:04 -0500
In-Reply-To: <alpine.DEB.2.00.0911301104520.16713@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> It seems that the current sip nat module in the kernel has only limited
> functionality. According to
> 
> http://people.netfilter.org/chentschel/docs/sip-conntrack-nat.html
> 
> one has to point the firewall at the target host for the SIP proxying to
> work. Therefore the kernel will only support a single inside phone
> connecting via SIP to the outside. For a network that has a series of
> phones inside the NAT zones this means that the firewall sip nat is not
> useful.

That documentation is horribly outdated.

> siproxd http://siproxd.sourceforge.net/ seems to be able to handle
> multiple outgoing SIP connections but one needs to specify an outbound
> proxy for each inside SIP phone.
> 
> Isnt there a way to make the kernel module work in the same way siproxd
> works and able to support multiple phones? Right now configuring SIP
> connectivity is a messy thing that is not easily setup. Can we fix this?

It should work fine with multiple phones, it even recognizes calls
between two internal phones and makes the media stream go between
them directly. Depending on how your registrar/proxy works, you might
have to set one or both of these module options:

sip_direct_signalling: when set to zero, allows incoming signalling
 connections from other hosts than the registrar. Usually not needed.

sip_direct_media: when set to zero, allows incoming media streams
 from other hosts than the registrar. This one is often required,
 some providers use server farms for handling the media streams,
 some set up media streams to go directly between the endpoints.

