From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [RFCv3 bluetooth-next 4/4] 6lowpan: iphc: add support for
 stateful compression
Date: Fri, 11 Dec 2015 18:05:46 +0100
Message-ID: <20151211170541.GA1119@omega>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-5-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38104 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbbLKRFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 12:05:54 -0500
Content-Disposition: inline
In-Reply-To: <1448796882-316-5-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

status update here.

I implemented successful basic 6CO RA messages at sending and
processing inside radvd.

There might also the question if processing 6CO inside kernel or
userspace? I put the basic functionality inside userspace for now.

I will send patches for this in the next days.

Anyway I figured some things out which was completely wrong inside this
patch.

 - There exist one context based table only.
   
   In rfc6282 stands:
   The specification enables a node to use up to 16 contexts. The
   context used to encode the source address does not have to be the
   same as the context used to encode the destination address.

   and I thought it was $SOME_TABLE[DCI] != $DIFFERENT_TABLE[SCI].
   But it means in general simple that it can be: DCI != SCI.

   With this knowledge the code gets much smaller.

 - I also remove the validation check for contexts, it can be any
   prefic/address. The lookup functionality will deal with that if the
   context looks not correct or need additional changes.

The table is very KISS for now. Not much additional functionality is
there, if somebody needs that it can handled by
$USERSPACE_RA_6CO_handler.

- Alex
