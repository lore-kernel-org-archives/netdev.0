From: Patrick McHardy <kaber@trash.net>
Subject: Re: [LARTC] Problem setting shift value in tcindex filter on big
 endian	machine
Date: Mon, 02 Apr 2007 14:13:33 +0200
Message-ID: <4610F36D.3020108@trash.net>
References: <460FA944.40902@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: lartc@mailman.ds9a.nl, Linux Netdev List <netdev@vger.kernel.org>
To: Ole Reinartz <ole.reinartz@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40704 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934002AbXDBMNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2007 08:13:36 -0400
In-Reply-To: <460FA944.40902@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please send bugreports to netdev@vger.kernel.org.

Ole Reinartz wrote:
> I'm trying to get some DiffServ QoS shaping to work on an XScale
> machine, running big endian. I'm setting it up with tc. Using the
> tcindex filter I found that regardless what shift value I enter, only
> '0' is returned when I list the filters afterwards. The very same rules
> work fine on my (little endian) PC.
> Looking at the code (iproute2-2.6.18-061002) I found that tc (in
> tc/f_tcindex.c, line 72 and after) sends the shift value to the kernel
> as an int. The kernel, however, expects it as a 'u16'
> (net/sched/cls_tcindex.c, around line 250 depending on the exact kernel
> version). I checked 2.6 kernel versions back until 2.6.11.


It appears this was broken during some ->change operation fixes
in 2.6.11.

> So... do we have a type mismatch here? As 'shift' is the last parameter
> in the buffer, this works still very well on a little endian machine,
> however on a big endian machine allways 0 is received in the kernel. To
> check that I changed the type of the shift value to unsigned short in
> tc, and that fixed it for me.
> Someone interested in a patch?


Yes, but its the kernel that needs to be fixed to expect a u32.

