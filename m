From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 10:08:30 +0100
Message-ID: <20080327090830.GB2778@ami.dom.local>
References: <bug-10326-10286@http.bugzilla.kernel.org/> <20080325134320.21525479.akpm@linux-foundation.org> <47EAD8A5.3070806@gmail.com> <20080326171403.ad186037.akpm@linux-foundation.org> <20080327085542.GA2778@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757440AbYC0JEe@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080327085542.GA2778@ami.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2008 at 09:55:42AM +0100, Jarek Poplawski wrote:
...
> sky2_poll() doesn't take napi->poll_lock; this lock is taken by
> netpoll_poll() before calling sky2_poll(). And before this hardirqs
> are disabled in write_msg().

Actually, hardirqs are disabled again before netpoll_poll() (in
netpoll_send_skb()), so sky2_poll() should need enable_irqs 2x
to justify such a warning.

Jarek P.
