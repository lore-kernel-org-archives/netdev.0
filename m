From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V4 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Thu, 30 Jul 2015 10:17:44 +0000
Message-ID: <4cd0704b1a324edc9330b11b006d8574@SIXPR30MB031.064d.mgd.msft.net>
References: <1438086923-19450-1-git-send-email-decui@microsoft.com>
 <20150729.152737.853332463848886188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150729.152737.853332463848886188.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: David Miller
> Sent: Thursday, July 30, 2015 6:28
> >From: Dexuan Cui
> >Date: Tue, 28 Jul 2015 05:35:23 -0700
> >
> > +/* hvsock_release() can be invoked in 2 paths:
> > + * 1. on process termination:
> > + *	hvsock_sk_destruct+0x1a/0x20
> > + *	__sk_free+0x1d/0x130
> > + *	sk_free+0x19/0x20
> > + *	hvsock_release+0x138/0x160
> > + *	sock_release+0x1f/0x90
> > + *	sock_close+0x12/0x20
> > + *	__fput+0xdf/0x1f0
> > + *	____fput+0xe/0x10
> > + *	task_work_run+0xd4/0xf0
> > + *	do_exit+0x334/0xb90
> > + *	? __do_page_fault+0x1e1/0x490
> > + *	? lockdep_sys_exit_thunk+0x35/0x67
> > + *	do_group_exit+0x54/0xe0
> > + *	SyS_exit_group+0x14/0x20
> > + *	system_call_fastpath+0x16/0x1b
> > + *
> > + *  2. when accept() returns -ENITR:
> > + *	hvsock_release+0x151/0x160
> > + *	sock_release+0x1f/0x90
> > + *	sock_close+0x12/0x20
> > + *	__fput+0xdf/0x1f0
> > + *	____fput+0xe/0x10
> > + *	task_work_run+0xb7/0xf0
> > + *	get_signal+0x750/0x770
> > + *	do_signal+0x28/0xbb0
> > + *	? put_unused_fd+0x52/0x60
> > + *	? SYSC_accept4+0x1ca/0x220
> > + *	do_notify_resume+0x4f/0x90
> > + *	int_signal+0x12/0x17
> > + */
> 
> It is a bit much to put full stack backtraces into a comment like this.

Thanks for reviewing the patch, David!
I'll remove these lines and add a proper comment here.

Thanks,
-- Dexuan
