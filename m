From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] tun: update file current position
Date: Fri, 06 Dec 2013 12:45:00 -0500 (EST)
Message-ID: <20131206.124500.1976272290413710707.davem@davemloft.net>
References: <1386320930-11285-1-git-send-email-zwu.kernel@gmail.com>
	<1386320930-11285-2-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wuzhy@linux.vnet.ibm.com
To: zwu.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386320930-11285-2-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <zwu.kernel@gmail.com>
Date: Fri,  6 Dec 2013 17:08:50 +0800

> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
> 
> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Also applied and queued up for -stable, thanks.

I noticed in these two cases that that min_t() adjustment of 'ret'
seems strange.  I can't understand why it's needed.

If, for example, tun_do_read() really did read more than 'len'
bytes:

1) That would write past the end of the buffer.

2) Writing a different value to the ->ki_pos would mean
   that ->ki_pos is now inaccurate.

Unless someone can explain why the min_t() is needed, we should remove
it.
