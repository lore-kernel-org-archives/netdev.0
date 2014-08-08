From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Xen-devel] [PATCH] xen-netback: Turn off the carrier if the
 guest is not able to receive
Date: Fri, 8 Aug 2014 09:33:56 -0700
Message-ID: <20140808093356.04d7228b@haswell.linuxnetplumber.net>
References: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com>
	<1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>
	<53DF8C24.6030709@citrix.com>
	<53DFA30E.2000301@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	<linux-kernel@vger.kernel.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:35680 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756037AbaHHQeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 12:34:02 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so7248247pdj.22
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 09:33:59 -0700 (PDT)
In-Reply-To: <53DFA30E.2000301@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This idea of bouncing carrier is wrong. If guest is flow blocked you don't
want to toggle carrier. That will cause problems because applications that are
looking for carrier transistions like routing daemons will be notified.

If running a routing daemon this will also lead to link flapping which
is very bad and cause lots of other work for peer routing daemons.

Carrier is not a suitable flow control mechanism.
