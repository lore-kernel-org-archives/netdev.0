From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 01:01:53 +0400
Message-ID: <20070723210153.GA5753@martell.zuzino.mipt.ru>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org> <20070723183839.GA5874@martell.zuzino.mipt.ru> <20070723190152.GA5755@martell.zuzino.mipt.ru> <20070723132431.42afbae8.akpm@linux-foundation.org> <20070723204045.GD5755@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:24243 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760836AbXGWVB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 17:01:58 -0400
Received: by ug-out-1314.google.com with SMTP id j3so35752ugf
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 14:01:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070723204045.GD5755@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 24, 2007 at 12:40:45AM +0400, Alexey Dobriyan wrote:
> > I had more complete info: http://article.gmane.org/gmane.linux.network/66966
> > 
> > You're using DEBUG_PAGEALLOC, but I was not, so I think we can rule that out.
> > 
> > I haven't worked out where that kmap_atomic() call is coming from yet. 
> > Both traces point up into the page allocator, but I _think_ that's stack
> > gunk.
> 
> Ahh, you suspect networking.
> 
> Here, setup is 2 cheap-ass 100Mb realtek 8139 NICs, one to campus network
> receiving ~20 junk packets per second, one gathering netconsole output
> and ssh to it, no conntracks and fancy stuff.
> 
> [reboots with cables physically unplugged]

OK, I run gdb recompile, cat(1) every file in /usr/portage (shitload of
small files) with both cables unplugged. It all went fine for ~5 minutes
after that it crashed exactly same way after 10 secs after plugging one
of them.

