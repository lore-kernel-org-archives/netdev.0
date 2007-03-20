From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Tue, 20 Mar 2007 10:25:20 -0600
Message-ID: <m1ircvswzz.fsf@ebiederm.dsl.xmission.com>
References: <20070319.120854.30182994.davem@davemloft.net>
	<20070319.204712.118947830.davem@davemloft.net>
	<m13b40wnrb.fsf@ebiederm.dsl.xmission.com>
	<200703201428.50564.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, netdev@vger.kernel.org, mingo@elte.hu,
   linux-kernel@vger.kernel.org, jbeulich@novell.com,
   virtualization@lists.linux-foundation.org, chrisw@sous-sol.org,
   virtualization@lists.osdl.org, anthony@codemonkey.ws,
   akpm@linux-foundation.org, torvalds@linux-foundation.org,
   David Miller <davem@davemloft.net>
To: Andi Kleen <ak@suse.de>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <200703201428.50564.ak@suse.de> (Andi Kleen's message of "Tue, 20
	Mar 2007 14:28:50 +0100")
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

Andi Kleen <ak@suse.de> writes:

>> I'm conflicted about the dwarf unwinder.  I was off doing other things
>> at the time so I missed the pain, but I do have a distinct recollection =
of
>> the back traces on x86_64 being distinctly worse the on i386. =

>
> The only case were i386 was better was with frame pointers, which
> was never fully implemented for x86-64. However i find that hilarious: =

> people are spending a lot of time right here in this thread to squeeze
> out the best call sequences for the paravirt ops, but then accept
> losing a full frame pointer register on i386. I never found that
> acceptable, that is why I prefered the unwinder instead. =

>
> This said the big problem with the frame pointers is mostly gone now:
> on older CPUs it tended to cause a pipeline stall early in the function.
> That is now fixed in the latest Intel/upcomming AMD CPUs, but there =

> are still millions and millions of older CPUs out there so I still
> don't consider it acceptable.

What I recall observing is call traces that made no sense.  Not just
extra noise in the stack trace but things like seeing a function that
has exactly one path to it, and not seeing all of the functions on
that path in the call trace.

In my later debugging I have been reasonably able to attribute those
kinds of things to compiler optimizations like inlining and tail call
optimization.

Now I will agree that having fewer or no false positives to weed
through is a good thing, if we can do it reliably.

>> Lately =

>> I haven't seen that so it may be I was misinterpreting what I was
>> seeing, and the compiler optimizations were what gave me such weird
>> back traces. =

>
> The main problem is that subsystems are getting more and more complex
> and especially callbacks seem to multiply far too quickly.
>
> In 2.4 it was often very reasonable to just sort out the false positives,
> but with sometimes 20-30+ level deep call chains in 2.6 with many callbac=
ks that
> just
> gets far too tenuous. =


Hmm.  I haven't seen those traces, but I wonder if the size of those
stack traces indicates potential stack overflow problems.
  =

>> But if the quality of our backtraces has gone down and dwarf unwinder
>> could give us better back traces it is likely worth pursuing.  Of
>> course it would need to start with the assumption that it's tables
>> may be borked (the kernel is busted after all) and be much more
>> careful than Andi's last attempt.
>
> The latest version validates the stack always. It was only a few lines
> of change. I doubt it will make much difference though. The few true cras=
hes
> we had were not actually due the unwinder itself, but the buggy fallback =
code
> (which were fixed quickly). But anyways it should satisfy everybody's par=
anoia
> now.

Do you also validate the unwind data?

> Although in future it would be good if people did some more analysis in r=
oot
> causes for failures before let the paranoia take over and revert patches.
>
> We see a good example here of what I call the JFS/ACPI effect: code gets =
merged
> too early with some visible problems. It gets a bad name and afterwards p=
eople
> never look objectively at it again and just trust their prejudices. =


I don't know.  The impression I got was the root cause analysis stopped =

when it was observed that the code was unsuitable for solving the problem.
When asked about it, it appeared the developer did not understand the
question.  Therefore the root cause was assumed to be the developer.

At least that is how I have read the few little bits I have seen.

> But that's not a good strategy to get good code in the end I think. If th=
ere
> is enough evidence the early problems were fixed then prejudices should
> be reevaluated.

Certainly.  However if the developer has lost a certain amount of
initial trust, the burden becomes much higher.

Eric
