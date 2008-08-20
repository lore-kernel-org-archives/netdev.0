From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- found another user with the same regression
Date: Wed, 20 Aug 2008 07:08:42 -0700 (PDT)
Message-ID: <705656.38463.qm@web82108.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82108.mail.mud.yahoo.com ([209.191.84.221]:44417 "HELO
	web82108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751101AbYHTOIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 10:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > This is true if he reverted just the 3def3d6d... commit, but if he
> > also reverts the similar, and immediately following, 1e934dda...
> > commit, then his 2.6.26 kernel runs fine.
> 
> interesting,
> 
> David, can you try only comment out
> 
> late_initcall(lapic_insert_resource);

Results with v2.6.27-rc3:  hangs in the same way, at the same place;
works with "hpet=disable".


I wondered whether changes since before v2.6.26-rc1 might interfere
with your intention here, so I checked out 1e934dda... and tried
again.

Results with 1e934dda...:  hangs, just like above.


Bill is right:  reverting the changes in 3def3d6d alone will not work 
on my hardware unless I also revert 1e934dda.

I have not (yet) attempted to bring those reverts forward to v2.6.27*
because I have been trying to identify the breakage that 3def3d6d
causes (and because I don't know the right git-fu to apply to my branch
to apply the post-v2.6.26 commits :(  ).


The other user who reported problems said that reverting3def3d6d alone
worked for him.  (I have asked him for more info on his blog, hoping he 
can tell us more... if there is more for him to tell.)  His kernel was 
NOT hanging in the same place as mine:

- mine hangs in inet_init(), after a series of calls that ends with
the hang at synchronize_rcu().

- his hangs (somewhere) inide_scan_pcibus().
[http://www.uwsg.indiana.edu/hypermail/linux/kernel/0805.2/1082.html]

He has a bug report (http://marc.info/?l=linux-kernel&m=121107133101187&w=2)
which lists his hardware as "Abit F-190HD motherboard with a Q6600 CPU".

My hardware -- 2 machines with the same regression -- is quite different:

"fileserver":  ECS AMD690GM-M2 mboard with AMD Athlon X2 4850e
"webserver":  ECS AMD690GM-M2 mboard with AMD Athlon 64 X2 3600+


Thanks,
Dave W.
