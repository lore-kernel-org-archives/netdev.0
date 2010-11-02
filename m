From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/3] offloading: Support multiple vlan tags in GSO.
Date: Mon, 1 Nov 2010 18:31:46 -0700
Message-ID: <AANLkTi=e2kqAmP5pPhQsRHL30Uw8PbZsxz+X8vpJKgWJ@mail.gmail.com>
References: <1288390495-28923-1-git-send-email-jesse@nicira.com>
	<1288390495-28923-2-git-send-email-jesse@nicira.com>
	<1288643630.2231.30.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55272 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab0KBBbr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 21:31:47 -0400
Received: by wyf28 with SMTP id 28so6140776wyf.19
        for <netdev@vger.kernel.org>; Mon, 01 Nov 2010 18:31:46 -0700 (PDT)
In-Reply-To: <1288643630.2231.30.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 1, 2010 at 1:33 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Fri, 2010-10-29 at 15:14 -0700, Jesse Gross wrote:
>> We assume that hardware TSO can't support multiple levels of vlan ta=
gs
>> but we allow it to be done. =A0Therefore, enable GSO to parse these =
tags
>> so we can fallback to software.
>>
>> Signed-off-by: Jesse Gross <jesse@nicira.com>
>> CC: Ben Hutchings <bhutchings@solarflare.com>
> [...]
>
> I can't see how TSO would be enabled on a second-level VLAN device;
> presumably you're thinking about GSO being enabled there?

Right, TSO can't be enabled on a stacked vlan device.  However, there
are a few ways that I can think of to hit this code path.  One is GSO,
another is encapsulating a bridged packet that is already tagged.

These are definitely corner cases and I can think of a few other
caveats when using them.  Mostly I'm just thinking about making it
robust in the face of weird corner cases, one piece at a time at
least.
