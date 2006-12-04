From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: RFC: consistent disable_xfrm behaviour
Date: Mon, 4 Dec 2006 19:52:53 +0300
Message-ID: <20061204165253.GA11905@ms2.inr.ac.ru>
References: <457437EA.7000406@trash.net> <XMMS.LNX.4.64.0612041005260.4314@d.namei> <45743CC1.1080904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:39311 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S937140AbWLDQx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 11:53:26 -0500
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <45743CC1.1080904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Alexey, do you remember what the original intent of this was?

disable_policy was supposed to skip policy checks on input.
It makes sense only on input device.

disable_xfrm was supposed to skip transformations on output.
It makes sense only on output device.

If it does not work, it was done wrong. :-)

As I see it, root of the problem is that DST_NOXFRM flag
is calculated using wrong device. out_dev should be used
in __mkroute_input(). It looks as a cut-n-paste error, the code
was taken from output path, where it is correct.
