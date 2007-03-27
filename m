From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Tue, 27 Mar 2007 13:32:09 +0200
Message-ID: <200703271332.09574.netdev@axxeo.de>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <46059EF8.6050603@trash.net> <46069F60.3020501@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:32809 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753818AbXC0LcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 07:32:22 -0400
In-Reply-To: <46069F60.3020501@katalix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

James Chapman schrieb:
> I thought seq_printf handled large output (multiple pages)? I am aware 
> of the page size limitation of raw proc handlers.

No. It does detect the limitation, discards your output an lets you try again,
when the next invocation of *_show()  has enough buffer space.
seq_puts() behaves the same. So you simply do this:

if (seq_puts(m, "text\n"))
	goto no_space;

Regards

Ingo Oeser
