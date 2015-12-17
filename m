From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: use-after-free in sixpack_close
Date: Thu, 17 Dec 2015 11:41:04 +0000
Message-ID: <20151217114104.6946d72b@lxorguk.ukuu.org.uk>
References: <CACT4Y+YfPHHON7VywV_G-qOyQ0wv6UVB0uxFAGf1aGKpfAP-KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Koensgen <ajk@comnets.uni-bremen.de>,
	linux-hams@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+YfPHHON7VywV_G-qOyQ0wv6UVB0uxFAGf1aGKpfAP-KA@mail.gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This report is then followed by a dozen of other use-after-free reports.
> 
> On commit edb42dc7bc0da0125ceacab810a553ce1f0cac8d (Dec 15).
> 
> Thank you

sixpack_close does unregister_netdev(sp->dev), which frees sp as sp is
actually allocated via alloc_netdev()

Then deletes two timers within sp

Then frees two buffers indexed off sp

The mkiss driver also appears to share the same bug and references
ax->rbuff/xbuff after they have been freed, and then writes to ax->tty.


Alan



