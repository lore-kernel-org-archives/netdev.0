From: "David S. Miller" <davem@redhat.com>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.49
Date: Tue, 26 Nov 2002 02:15:46 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021126.021546.91313706.davem@redhat.com>
References: <3DE33D6D.25B9C9B4@isg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: srompf@isg.de
In-Reply-To: <3DE33D6D.25B9C9B4@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This locking below achieves nothing.

+	read_lock_irqsave(&dev->operstate_lock, flags);
+	state = dev->operstate;
+	read_unlock_irqrestore(&dev->operstate_lock, flags);

In fact, the other side, locking when setting this value, can
be done with a simple spinlock.  Probably something else in
the device struct can be reused.

I also don't think this should be conditional, either we want
it or we don't.
