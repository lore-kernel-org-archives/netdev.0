From: Luca Maranzano <liuk001@gmail.com>
Subject: Re: ipvs_syncmaster brings cpu to 100%
Date: Mon, 26 Sep 2005 15:52:02 +0200
Message-ID: <68559cef05092606521cc13f9a__39477.8677299202$1127742994$gmane$org@mail.gmail.com>
References: <68559cef050908090657fc2599@mail.gmail.com>
	 <498263350509081605956a771@mail.gmail.com>
	 <68559cef05092207022f1f0df4@mail.gmail.com>
	 <498263350509230815eb08a73@mail.gmail.com>
	 <20050926032807.GI18357@verge.net.au>
	 <20050926043400.GD5079@us.ibm.com>
	 <20050926080508.GF11027@verge.net.au>
	 <20050926081229.GA23755@verge.net.au>
	 <20050926131104.GA7532@us.ibm.com>
Reply-To: Luca Maranzano <liuk001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "LinuxVirtualServer.org users mailing list." <lvs-users@linuxvirtualserver.org>,
        Dave Miller <davem@davemloft.net>,
        Wensong Zhang <wensong@linux-vs.org>, Julian Anastasov <ja@ssi.bg>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050926131104.GA7532@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Just to add more info, please note the output of "ps":

debld1:~# ps aux|grep ipvs
root      3748  0.0  0.0      0     0 ?        D    12:09   0:00
[ipvs_syncmaster]
root      3757  0.0  0.0      0     0 ?        D    12:09   0:00
[ipvs_syncbackup]

Note the D status, i.e. (from ps(1) man page): Uninterruptible sleep
(usually IO)

I hope to have a Xeon machine to make some more tests in the next
days, in the mean time I'll try to reproduce my setup on a couple of
VMWare Workstation machines.

More later.
Thank you all.
Luca



On 26/09/05, Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> On 26.09.2005 [17:12:32 +0900], Horms wrote:
> > On Mon, Sep 26, 2005 at 05:05:10PM +0900, Horms wrote:
> >
> > [snip]
> >
> > > > > > > Furthermore, if I make an "rgrep" in the source tree of kernel 2.6.12
> > > > > > > the function schedule_timeout() is more used than the ssleep() (517
> > > > > > > occurrencies vs. 43), so why in ip_vs_sync.c there was this change?
> > > > > > >
> > > > > > > The other oddity is that Horms reported on this list that on non Xeon
> > > > > > > CPU the same version of kernel of mine does not present the problem.
> > > > > > >
> > > > > > > I'm getting crazy :-)
> > > > >
> > > > > I've prepared a patch, which reverts the change which was introduced
> > > > > by Nishanth Aravamudan in February.
> > > >
> > > > Was the 100% cpu utilization only occurring on Xeon processors?
> > >
> > > That seems to be the only case where were this problem has been
> > > observed. I don't have such a processor myself, so I haven't actually
> > > been able to produce the problem locally.
> > >
> > > One reason I posted this issue to netdev was to get some more
> > > eyes on the problem as it is puzzling to say the least.
> > >
> > > > Care to try to use msleep_interruptible() instead of ssleep(), as
> > > > opposed to schedule_timeout()?
> > >
> > > I will send a version that does that shortly, Luca, can
> > > you plase check that too?
> >
> > Here is that version of the patch. Nishanth, I take it that I do not
> > need to set TASK_INTERRUPTABLE before calling msleep_interruptible(),
> > please let me know if I am wrong.
>
> Yes, exactly. I'm just trying to narrow it down to see if it's the task
> state that's causing the issue (which, to be honest, doesn't make a lot
> of sense to me -- with ssleep() your load average will go up as the task
> will be UNINTERRUPTIBLE state, but I am not sure why utilisation would
> rise, as you are still sleeping...)
>
> Thanks,
> Nish
>
