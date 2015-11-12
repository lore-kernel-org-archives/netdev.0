From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] ip_tunnel: disable preemption when updating per-cpu tstats
Date: Thu, 12 Nov 2015 17:52:18 +0100
Message-ID: <CAHmME9r5bJqX-XRK4iPkkB_bL77=kAO4askgb4DZ_cvAHfSxfA@mail.gmail.com>
References: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
	<1447345509.2333208.438003833.012C1A95@webmail.messagingengine.com>
	<CAHmME9qF2Xi91BTWNSXBoDmzxyPyqSPbFg8ZDN4S-0kSq-RtKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9qF2Xi91BTWNSXBoDmzxyPyqSPbFg8ZDN4S-0kSq-RtKA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By the way, in case anybody is interested, I've done a little bit of
historical digging work. The functions in question date back to
aa0010f8 from 2012. Before that commit, statistics structures would be
incremented after each tunnel's driver itself dereferenced the per-cpu
variable. When this got factored out into iptunnel_xmit_stats, the
author of aa0010f8 simply took the code from the tunnel drivers, which
included the use of "this_cpu_ptr" instead of "get_cpu_ptr", because
presumably each driver was able to ensure preemption was disabled in
its codepath. With the generalization of this functionality into the
globally useful iptunnel_xmit_stats, we'll need to be using
"get_cpu_ptr" instead.
