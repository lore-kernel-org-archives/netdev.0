From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/9 v2] net: Refactor ip_route_input_slow
Date: Wed, 23 Sep 2015 08:30:39 -0700
Message-ID: <1443022239.29850.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33985 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbbIWPan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:30:43 -0400
Received: by padhy16 with SMTP id hy16so43577453pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:30:42 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-23 at 08:15 -0700, David Ahern wrote:
> ip_route_input_slow is a maze of gotos (9 of them!) making it error
> prone and difficult to read. This patchset refactors it, removing all
> but 2 of the labels. The brd_input label for broadcast path requires
> too many inputs to make a reasonble helper out of it so I left it as is.
> 
> None of these patches change functionality, only move code around
> to make ip_route_input_slow more readable.

This kind of work, might ease your job (pushing new functions in the
future kernels), but make stable teams work a nightmare.

You also remove a lot of goto, but do not place likely() or unlikely()
clauses that would help compiler to emit the same optimal code.

gotos have quite nice properties, forget what you might have learn in
some CS classes.
