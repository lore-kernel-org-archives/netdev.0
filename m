From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Mon, 19 Mar 2007 22:19:04 -0600
Message-ID: <m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
References: <20070319.120854.30182994.davem@davemloft.net>
	<200703192159.42396.ak@suse.de>
	<Pine.LNX.4.64.0703192015020.6730@woody.linux-foundation.org>
	<20070319.204712.118947830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
   linux-kernel@vger.kernel.org, jbeulich@novell.com, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, anthony@codemonkey.ws,
   akpm@linux-foundation.org, virtualization@lists.linux-foundation.org,
   torvalds@linux-foundation.org, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20070319.204712.118947830.davem@davemloft.net> (David Miller's
	message of "Mon, 19 Mar 2007 20:47:12 -0700 (PDT)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Mon, 19 Mar 2007 20:18:14 -0700 (PDT)
>
>> > > Please don't subject us to another couple months of hair-pulling only
>> > > to have Linus yank the thing out again, there are certainly more
>> > > useful things to spend time on :-)
>> =

>> Good call. Dwarf2 unwinding simply isn't worth doing. But I won't yank i=
t =

>> out, I simply won't merge it. It was more than just totally buggy code, =
it =

>> was an inability of the people to understand that even bugfree code =

>> isn't enough - you have to be able to also handle buggy data.
>
> Thank you.

Hmm..

I know the feeling I have had a similar rant about the kexec on panic
code path.   The code is still no where near as paranoid about normal
kernel things not working as it could be, but by ranting about it
periodically the people doing the work are gradually making it better.

I'm conflicted about the dwarf unwinder.  I was off doing other things
at the time so I missed the pain, but I do have a distinct recollection of
the back traces on x86_64 being distinctly worse the on i386.  Lately
I haven't seen that so it may be I was misinterpreting what I was
seeing, and the compiler optimizations were what gave me such weird
back traces.  =


But if the quality of our backtraces has gone down and dwarf unwinder
could give us better back traces it is likely worth pursuing.  Of
course it would need to start with the assumption that it's tables
may be borked (the kernel is busted after all) and be much more
careful than Andi's last attempt.

Eric
