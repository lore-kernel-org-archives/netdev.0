From: Patrick McHardy <kaber@trash.net>
Subject: Re: SIP proxying: siproxd vs. Netfilter SIP nat
Date: Mon, 30 Nov 2009 18:30:17 +0100
Message-ID: <4B140129.2050907@trash.net>
References: <alpine.DEB.2.00.0911301104520.16713@router.home> <4B13FF05.5060005@trash.net> <alpine.DEB.2.00.0911301123110.17037@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Christian Hentschel <chentschel@arnet.com.ar>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55940 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015AbZK3RaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 12:30:11 -0500
In-Reply-To: <alpine.DEB.2.00.0911301123110.17037@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> On Mon, 30 Nov 2009, Patrick McHardy wrote:
> 
>>> http://people.netfilter.org/chentschel/docs/sip-conntrack-nat.html
>> That documentation is horribly outdated.
> 
> Where do I find more recent documentation?

Below :)

>>> Isnt there a way to make the kernel module work in the same way siproxd
>>> works and able to support multiple phones? Right now configuring SIP
>>> connectivity is a messy thing that is not easily setup. Can we fix this?
>> It should work fine with multiple phones, it even recognizes calls
>> between two internal phones and makes the media stream go between
>> them directly. Depending on how your registrar/proxy works, you might
>> have to set one or both of these module options:
> 
> Loaded both sip modules without specifying any parameters. Resulted in one
> way audio problems which is what I also get without the modules.
> 
>> sip_direct_signalling: when set to zero, allows incoming signalling
>>  connections from other hosts than the registrar. Usually not needed.
>>
>> sip_direct_media: when set to zero, allows incoming media streams
>>  from other hosts than the registrar. This one is often required,
>>  some providers use server farms for handling the media streams,
>>  some set up media streams to go directly between the endpoints.
> 
> Ok will try setting that parameter to zero.

You of course also need to accept the packets marked RELATED by
the helper. If this is missing it might result in one-way audio.
