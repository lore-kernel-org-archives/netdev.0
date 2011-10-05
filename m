From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH 0/8] skb fragment API: convert network drivers (part IV)
Date: Wed, 5 Oct 2011 11:28:30 +0100
Message-ID: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:64502 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934188Ab1JEK2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 06:28:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series converts a forth batch of network drivers to the
SKB pages fragment API introduced in 131ea6675c76.

There are two drivers/staging patches in here. I'm not sure who normally
takes these, I'm sure you guys know though.

After this batch there are ~4 drivers which need a little more thought
(the inevitable fifth out of four series...). Specifically these drivers
will switch from skb_frag_t -> struct subpage (which I am going to
introduce shortly) in their internal data structures, this will isolate
them from changes to skb_frag_t coming from the network core.

This is part of my series to enable visibility into SKB paged fragment's
lifecycles, [0] contains some more background and rationale but
basically the completed series will allow entities which inject pages
into the networking stack to receive a notification when the stack has
really finished with those pages (i.e. including retransmissions,
clones, pull-ups etc) and not just when the original skb is finished
with, which is beneficial to many subsystems which wish to inject pages
into the network stack without giving up full ownership of those page's
lifecycle. It implements something broadly along the lines of what was
described in [1].

Cheers,
Ian.

[0] http://marc.info/?l=linux-netdev&m=131072801125521&w=2
[1] http://marc.info/?l=linux-netdev&m=130925719513084&w=2
