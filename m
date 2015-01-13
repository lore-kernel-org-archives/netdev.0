From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fwd: [rhashtable] WARNING: CPU: 0 PID: 10 at
 kernel/locking/mutex.c:570 mutex_lock_nested()
Date: Tue, 13 Jan 2015 19:28:47 +0000
Message-ID: <20150113192847.GP20387@casper.infradead.org>
References: <20150110194803.GA9033@wfg-t540p.sh.intel.com>
 <54B3259B.7080601@windriver.com>
 <20150112124216.GA26570@casper.infradead.org>
 <54B4CE3E.8020009@windriver.com>
 <20150113084126.GE20387@casper.infradead.org>
 <CAHA+R7M1ZSCF+FwKVtZUbsJ05zesNg-WVTqH13=oFe5gM--3gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lkp@01.org, Netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHA+R7M1ZSCF+FwKVtZUbsJ05zesNg-WVTqH13=oFe5gM--3gw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/15 at 11:14am, Cong Wang wrote:
> On Tue, Jan 13, 2015 at 12:41 AM, Thomas Graf <tgraf@suug.ch> wrote:
> > I can't reproduce it in my KVM box either so far. It looks like a
> > mutex_lock() on an uninitialized mutex or use after free but I can't
> > find such a code path so far.
> 
> Couldn't that be the delayed work is still running after rhashtable
> is destroyed by its caller? I mean, cancel_delayed_work_sync()
> should be called in rhashtable_destroy()?
> 
> Of course, it may be caller's responsibility to ensure that, I haven't
> looked into it that much.

Yes, we came to the very same conclusion in a different email thread
and found the offending race condition.
