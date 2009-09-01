From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: H.245v10+ support in nf_conntrack_h323?
Date: Tue, 1 Sep 2009 13:32:40 +0100
Message-ID: <20090901123240.GE18651@sirena.org.uk>
References: <20090901092910.GC11354@urbino.open.ch> <20090901100230.GA18651@sirena.org.uk> <4A9D04A2.60307@trash.net> <20090901121033.GA18731@urbino.open.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jing Min Zhao <zhaojingmin@users.sourceforge.net>,
	netdev@vger.kernel.org
To: Andreas Jaggi <aj@open.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:44672 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359AbZIAMck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 08:32:40 -0400
Content-Disposition: inline
In-Reply-To: <20090901121033.GA18731@urbino.open.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 01, 2009 at 02:10:33PM +0200, Andreas Jaggi wrote:

> For me it looks like nf_conntrack_h323 is not only doing connection
> tracking, but also doing protocol enforcement (by dropping packets which
> do not correspond exactly to H.245v7).
> Perhaps there should be a config option to disable the protocol
> enforcement?

It's not going to be a deliberate attempt at enforcement that's the
issue here - doing any substantial enforcement would require a full
decode of the PER messages, involving having a full copy of the (rather
large) ASN.1 in the kernel.  It's much more likely that a shortcut taken
in decoding the message is getting confused by something that the
endpoint is choosing to send, a brief glance at the ASN.1 code certainly
suggests that to me.  Chances are it's not even a new v10 feature that's
causing the issue.
