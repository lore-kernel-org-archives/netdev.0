From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: debug: nt_conntrack and KVM crash
Date: Mon, 01 Feb 2010 05:53:19 -0500
Message-ID: <1265021599.7499.176.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265020552.7499.147.camel@tonnant>
	 <b6fcc0a1002010244j161f7f0bob46053efc0d65630@mail.gmail.com>
	 <b6fcc0a1002010247s70b855b6kea66c99c9326b6a@mail.gmail.com>
	 <b6fcc0a1002010249y19e2edc3g7974f44633859bd3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b6fcc0a1002010249y19e2edc3g7974f44633859bd3@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-02-01 at 12:49 +0200, Alexey Dobriyan wrote:
> On Mon, Feb 1, 2010 at 12:47 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> > Or even printk nf_conntrack_htable_size during bootup and panic/oops.
> 
> Oh, sorry, I see it was indeed corrupted.

Right. And it's not just the set size function that changes the value
(it wasn't in this case) so it's not sufficient to say that there is a
generic function to set the size. That only applies to the hashtable in
the global init_net anyway, changing the hashtable sizes and then
leaving the existing hashes as they were.

Additionally, the size is writeable in the module sysfs entry. So it's
not read only, even though I agree that the procfs visable entry is. I
really think this does need fixing, and I'm not just being a pain in the
ass - I have another issue here clearly with memory corruption, but the
need for this to be cleaned up is real.

Jon.


