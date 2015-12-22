From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Tue, 22 Dec 2015 22:28:43 +0100
Message-ID: <20151222212843.GE4424@torres.zugschlus.de>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:41954 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353AbbLVV2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:28:44 -0500
Received: from mh by torres.zugschlus.de with local (Exim 4.80)
	(envelope-from <mh+netdev@zugschlus.de>)
	id 1aBUU7-0005zU-IP
	for netdev@vger.kernel.org; Tue, 22 Dec 2015 22:28:43 +0100
Content-Disposition: inline
In-Reply-To: <56796902.8080703@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

thanks for your mail.

On Tue, Dec 22, 2015 at 04:15:14PM +0100, Hannes Frederic Sowa wrote:
> On 12.12.2015 20:58, Marc Haber wrote:
> > Any hints would be appreciated.
> 
> This sysctl should help:
> 
> accept_ra_from_local - BOOLEAN
>         Accept RA with source-address that is found on local machine
>         if the RA is otherwise proper and able to be accepted.
>         Default is to NOT accept these as it may be an un-intended
>         network loop.
> 
>         Functional default:
>            enabled if accept_ra_from_local is enabled
>                on a specific interface.
>            disabled if accept_ra_from_local is disabled
>                on a specific interface.
> 
> Anyway, this has to be fixed up in a clean way and should work by default.

The clean way would be:

accept_ra_from_local=0: never accept RA with source-address that is
  found on local machine
accept_ra_from_local=1: always accept RA with source-address that is
  found on local machine. Dangerous.
accept_ra_from_local=2: only accept RA with link local source-address
  that is found on local machine, and not if received RA points to an
  address that is locally configured on the same interface. Default.

Shall I file a bug for this in bugzilla?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
