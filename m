From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [take2 0/4] kevent: introduction.
Date: Tue, 1 Aug 2006 13:34:04 +0400
Message-ID: <11544248443344@2ka.mipt.ru>
References: <20060731103322.GA1898@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751550AbWHAJKZ@vger.kernel.org>
In-Reply-To: <20060731103322.GA1898@2ka.mipt.ru>
To: lkml <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I send this patchset for comments and review, it still contains AIO and 
aio_sendfile() implementation on top of get_block() abstraction, which was
decided to postpone for a while (it is simpler right now to generate patchset as a whole,
when kevent will be ready for merge, I will generate patchset without AIO stuff).
It does not contain mapped buffer implementation, since it's design is not 100% 
completed, I will present that implementation in the third patchset.

Changes from previous patchset:
 - rebased against 2.6.18-git tree
 - removed ioctl controlling
 - added new syscall kevent_get_events(int fd, unsigned int min_nr, unsigned int max_nr,
			unsigned int timeout, void __user *buf, unsigned flags)
 - use old syscall kevent_ctl for creation/removing, modification and initial kevent 
	initialization
 - use mutuxes instead of semaphores
 - added file descriptor check and return error if provided descriptor does not match
	kevent file operations
 - various indent fixes
 - removed aio_sendfile() declarations.

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
