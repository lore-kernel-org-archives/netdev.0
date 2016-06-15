From: Blair Steven <Blair.Steven@alliedtelesis.co.nz>
Subject: Re: [PATCH] IPsec NAT-T issue
Date: Wed, 15 Jun 2016 00:44:54 +0000
Message-ID: <5760A501.3070504@alliedtelesis.co.nz>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
 <20160613102024.GX7698@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:60804 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932223AbcFOAo7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 20:44:59 -0400
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id F0BB28604B
	for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 12:44:55 +1200 (NZST)
In-Reply-To: <20160613102024.GX7698@gauss.secunet.com>
Content-Language: en-US
Content-ID: <AE0B84439B5183469F21451012A2FA97@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The restoration is happening - but being actioned on the wrong location.

The destination IP address is being saved and restored, and the SPI 
being written directly after the destination IP address. From my 
understanding though, the ESN shuffling should have saved and restored 
the UDP source / dest ports + SPI.

-Blair

On 06/13/2016 10:20 PM, Steffen Klassert wrote:
> On Mon, Jun 13, 2016 at 11:48:13AM +1200, Blair Steven wrote:
>> During testing we have discovered an issue with IPsec NAT-T where the SPI
>> is over writing the source and dest ports of the UDP header.
> The headers should be restored after the crypto operation in
> esp_restore_header(). Does this not happen in your case? What
> kind of problem do you experience?
>
