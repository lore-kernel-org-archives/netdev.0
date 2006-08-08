From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [take5 0/4] kevent: Generic event handling mechanism.
Date: Tue, 8 Aug 2006 11:44:46 +0400
Message-ID: <11550230861383@2ka.mipt.ru>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from user-edvans3.msk.internet2.ru ([217.25.93.4]:11971 "EHLO
	uganda.factory.vocord.ru") by vger.kernel.org with ESMTP
	id S932514AbWHHHUc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 03:20:32 -0400
In-Reply-To: <20060731103322.GA1898@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Generic event handling mechanism.

I send this patchset for comments and review, it still contains AIO and 
aio_sendfile() implementation on top of get_block() abstraction, which was
decided to postpone for a while (it is simpler right now to generate patchset as a whole,
when kevent will be ready for merge, I will generate patchset without AIO stuff).

Since number of suggested changes goes from 'several' to 'very small', I'm asking for 
inclusion or declining. Currently only AIO stuff requires some changes, and as sugested by 
Christoph Hellwig, will not supposed to be merged right now.

Should I prepare final patchset and what should it include?
Thank you.

Changes from 'take4' patchset:
 * use miscdevice instead of chardevice
 * comments fixes

Changes from 'take3' patchset:
 * removed serializing mutex from kevent_user_wait()
 * moved storage list processing to RCU
 * removed lockdep screaming - all storage locks are initialized in the same function, so it was learned 
	to differentiate between various cases
 * remove kevent from storage if is marked as broken after callback
 * fixed a typo in mmaped buffer implementation which would end up in wrong index calcualtion 

Changes from 'take2' patchset:
 * split kevent_finish_user() to locked and unlocked variants
 * do not use KEVENT_STAT ifdefs, use inline functions instead
 * use array of callbacks of each type instead of each kevent callback initialization
 * changed name of ukevent guarding lock
 * use only one kevent lock in kevent_user for all hash buckets instead of per-bucket locks
 * do not use kevent_user_ctl structure instead provide needed arguments as syscall parameters
 * various indent cleanups
 * added optimisation, which is aimed to help when a lot of kevents are being copied from userspace
 * mapped buffer (initial) implementation (no userspace yet)

Changes from 'take1' patchset:
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


