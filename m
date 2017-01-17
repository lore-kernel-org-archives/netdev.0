From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Mon, 16 Jan 2017 22:53:07 -0500
Message-ID: <20170117035307.GA1095@madcap2.tricolour.ca>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
	<1484318543.5300.1.camel@redhat.com>
	<CAHC9VhQsL7c=dAd4ZyTbEugkcrNuaxGNnaOi8oMkn=NCwuVoHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Steve@redhat.com, linux-audit@redhat.com,
        linux-kernel@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-audit-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <CAHC9VhQsL7c=dAd4ZyTbEugkcrNuaxGNnaOi8oMkn=NCwuVoHA@mail.gmail.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On 2017-01-16 15:04, Paul Moore wrote:
> On Fri, Jan 13, 2017 at 9:42 AM, Eric Paris <eparis@redhat.com> wrote:
> > On Fri, 2017-01-13 at 04:51 -0500, Richard Guy Briggs wrote:
> >> diff --git a/include/linux/audit.h b/include/linux/audit.h
> >> index 9d4443f..43d8003 100644
> >> --- a/include/linux/audit.h
> >> +++ b/include/linux/audit.h
> >> @@ -387,6 +387,18 @@ static inline int audit_socketcall(int nargs,
> >> unsigned long *args)
> >>               return __audit_socketcall(nargs, args);
> >>       return 0;
> >>  }
> >> +static inline int audit_socketcall_compat(int nargs, u32 *args)
> >> +{
> >> +     if (unlikely(!audit_dummy_context())) {
> >
> > I've always hated these likely/unlikely. Mostly because I think they
> > are so often wrong. I believe this says that you compiled audit in but
> > you expect it to be explicitly disabled. While that is (recently) true
> > in Fedora I highly doubt that's true on the vast majority of systems
> > that have audit compiled in.
> 
> Richard and I have talked about the likely/unlikely optimization
> before and I know Richard likes to use them, but I don't for the
> reasons Eric has already mentioned.   Richard, since you're respinning
> the patch, go ahead and yank out the unlikely() call.

I don't "like to use them".  I'm simply following the use and style of
existing code and the arguments of others in places of critical
performance.  If I "fix" that one, then I would feel compelled to yank
out the one in the function immediately above, audit_socketcall() for
consistency to ease my conscience.  Eric conceded that argument.

> paul moore

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
