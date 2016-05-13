From: Yichen Zhao <zhaoyichen@google.com>
Subject: Re: [PATCH] Bluetooth: Fix l2cap_sock_teardown_cb race condition with bt_accept_dequeue
Date: Fri, 13 May 2016 14:00:30 -0700
Message-ID: <1463173230-16159-1-git-send-email-zhaoyichen@google.com>
References: <45EE47FA-D319-4091-941A-C4005E32B572@holtmann.org>
Cc: Yichen Zhao <zhaoyichen@google.com>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <45EE47FA-D319-4091-941A-C4005E32B572@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcel,

> so I am not big fan of the conditional locking in case of parent is set or not. Do you have a test case that reproduces the mentioned race. It would love to have that in tools/l2cap-tester or similar.

So far I could only reproduce the bug by repeatedly performing RFCOMM connections and resets. I'll try to implement something in rfcomm-tester or l2cap-tester.

Since this is a race condition, I'm not confident that I can help you reproduce the bug reliably on a different test setup. I'd appreciate it very much if you can offer any tips on triggering a race condition faster in a test case.

> Maybe the code needs some restructuring to avoid the conditional locking.

I agree that my patch is not very elegant, and I'd love any way to improve it.
I have some ideas, but I'm not familiar enough with kernel development to know whether other solutions are safe to implement, such as:

* Removing bt_accept_unlink from l2cap_teardown_cb, and relying on bt_accept_dequeue to unlink the socket when it's enumerated. Is it safe to leave a zapped sock in accept_q?
* Perform "unlock sock; lock parent; lock sock" before calling bt_accept_unlink in teardown_cb. This is still conditional locking, but around a smaller block of code. Is it safe to unlock a zapped sock?
* Use RCU for handling accept_q. Is this appropriate?

Please let me know what you think.

Regards,

Yichen Zhao
