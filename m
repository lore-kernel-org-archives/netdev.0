From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Resource leak in unshare
Date: Tue, 03 Nov 2015 04:48:00 -0800
Message-ID: <1446554880.23275.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
	 <87oafcrzsa.fsf@x220.int.ebiederm.org>
	 <CACT4Y+arcDq=-kDn=y6oRFRSMApKKA7GrfAg_svTtLOVnnaVDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: syzkaller <syzkaller@googlegroups.com>,
	David Miller <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+arcDq=-kDn=y6oRFRSMApKKA7GrfAg_svTtLOVnnaVDA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-11-03 at 09:48 +0100, Dmitry Vyukov wrote:
> On Mon, Nov 2, 2015 at 8:01 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> > Dmitry Vyukov <dvyukov@google.com> writes:
> >
> >> Hello,
> >>
> >> I am hitting the following warnings on
> >> bcee19f424a0d8c26ecf2607b73c690802658b29 (4.3):
> >
> > Do you have any trace of the earlier failures?
> >
> > This appears to be something caused by an earlier failure (possibly
> > whatever fails to allocate memory).  Having network devices present
> > but being in the generic cleanup routines is wrong.
> >
> > If there is no additional information can you please rerun with the
> > following change applied?  That should at least report which function is
> > failing, and give us a good clue where to start debugging this.
> 
> 
> So is it all fixed now? Or it is still clear how it can happen?
> Eric (Dumazet), do you see how the WARNING can fire?
> I don't have any logs at the moment, but I can run fuzzer for longer
> to reproduce it again if necessary.

No idea.

I fixed a completely different bug I think, while simply looking at sit
code, since your report mentioned a sit0 name.

Namely a pure memory leak.

We have hundred of old bugs yet to fix. Not counting the new ones that
we'll add while fixing them.

Feel free to run your fuzzer of course.
