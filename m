From: Colin Cross <ccross@android.com>
Subject: Re: [PATCH 2/2] lockdep: check that no locks held at freeze time
Date: Mon, 6 May 2013 12:30:19 -0700
Message-ID: <CAMbhsRRcfpXBGAPThjrmB_judgn85TioR_6A6qwh_fBQCent7A@mail.gmail.com>
References: <1367615050-3894-1-git-send-email-ccross@android.com>
	<1367615050-3894-2-git-send-email-ccross@android.com>
	<20130506190115.GB800@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Paul Walmsley <paul@pwsan.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oleg Nesterov <oleg@redhat.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	Linux PM list <linux-pm@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ben Chan <benchan@chromium.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130506190115.GB800@mtj.dyndns.org>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 6, 2013 at 12:01 PM, Tejun Heo <tj@kernel.org> wrote:
> On Fri, May 03, 2013 at 02:04:10PM -0700, Colin Cross wrote:
>> From: Mandeep Singh Baines <msb@chromium.org>
>>
>> We shouldn't try_to_freeze if locks are held.  Holding a lock can cause a
>> deadlock if the lock is later acquired in the suspend or hibernate path
>> (e.g.  by dpm).  Holding a lock can also cause a deadlock in the case of
>> cgroup_freezer if a lock is held inside a frozen cgroup that is later
>> acquired by a process outside that group.
>>
>> History:
>> This patch was originally applied as 6aa9707099c and reverted in
>> dbf520a9d7d4 because NFS was freezing with locks held.  It was
>> deemed better to keep the bad freeze point in NFS to allow laptops
>> to suspend consistently.  The previous patch in this series converts
>> NFS to call _unsafe versions of the freezable helpers so that
>> lockdep doesn't complain about them until a more correct fix
>> can be applied.
>
> I don't care about %current change, especially given that it's a debug
> interface but that really should be a separate patch, so please split
> it out if you want it (and I think we want it).

The current change was requested by akpm and was part of the original
patch.  Is it really worth confusing the history of this patch even
more, applying it the first time, reverting it, and then applying it
again in two parts?
