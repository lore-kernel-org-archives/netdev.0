From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 06 Aug 2007 17:19:03 -0400
Message-ID: <46B79047.4060402@redhat.com>
References: <JMDDIG$C8916D611655799A77AD19198F8EDA75@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mingo <mingo@elte.hu>, "marcin.slusarz" <marcin.slusarz@gmail.com>,
	jarkao2 <jarkao2@o2.pl>, tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <JMDDIG$C8916D611655799A77AD19198F8EDA75@xandmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2007 04:42 PM, Jean-Baptiste Vignaud wrote:
> Mmm, bad news, after 4 hours of intensive network stressing, one of the 2 3com card failed with the latest fedora kernel.
> 
> Aug  6 22:31:09 loki kernel: NETDEV WATCHDOG: eth2: transmit timed out
> Aug  6 22:31:09 loki kernel: eth2: transmit timed out, tx_status 00 status e601.
> Aug  6 22:31:09 loki kernel:   diagnostics: net 0ccc media 8880 dma 0000003a fifo 8000
> Aug  6 22:31:09 loki kernel: eth2: Interrupt posted but not delivered -- IRQ blocked by another device?
> Aug  6 22:31:09 loki kernel:   Flags; bus-master 1, dirty 26085000(8) current 26085000(8)
> Aug  6 22:31:09 loki kernel:   Transmit list 00000000 vs. ffff81007c807700.
> 
> Stressing eth2 by copying large files on a samba on share and eth0 by downloading big files on the internet.

So even the full revert doesn't fix the 3Com driver, it just makes it less
likely to do that.

The other patch probably won't be any better -- I'd guess there's some
kind of IRQ handling bug in that driver.
