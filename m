From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH V2] audit: log 32-bit socketcalls
Date: Mon, 16 Jan 2017 23:03:50 -0500
Message-ID: <20170117040350.GB1095@madcap2.tricolour.ca>
References: <dd937da01da72da9277e44ed79abd1f4618c14c5.1484297765.git.rgb@redhat.com>
 <20170116.132745.1831536278596554491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-audit@redhat.com, aixer77@gmail.com, eparis@redhat.com,
        pmoore@redhat.com, sgrubb@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170116.132745.1831536278596554491.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-01-16 13:27, David Miller wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Fri, 13 Jan 2017 04:51:48 -0500
> 
> > diff --git a/include/linux/audit.h b/include/linux/audit.h
> > index 9d4443f..43d8003 100644
> > --- a/include/linux/audit.h
> > +++ b/include/linux/audit.h
> > @@ -387,6 +387,18 @@ static inline int audit_socketcall(int nargs, unsigned long *args)
> >  		return __audit_socketcall(nargs, args);
> >  	return 0;
> >  }
> > +static inline int audit_socketcall_compat(int nargs, u32 *args)
> > +{
> 
> Please put an empty line between function definitions.

Ok, should I reformat the rest of the file while I'm at it?

> > +	if (unlikely(!audit_dummy_context())) {
> > +		int i;
> > +		unsigned long a[AUDITSC_ARGS];
> 
> Please order local variable declarations from longest to shortest line.

Ok.  Is this a recent addition to a style guide or in checkpatch.pl?

> > +
> > +		for (i=0; i<nargs; i++)
> 
> Please put a space around operators such as "=" and "<".

Oops, my bad...

> > +			a[i] = (unsigned long)args[i];
> > +		return __audit_socketcall(nargs, a);
> > +	}
> > +	return 0;
> > +}
> >  static inline int audit_sockaddr(int len, void *addr)
> 
> Again, empty line between function definitions please.
> 
> > @@ -781,14 +782,24 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
> >  
> >  COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
> >  {
> > +	unsigned int len;
> >  	int ret;
> > -	u32 a[6];
> > +	u32 a[AUDITSC_ARGS];
> >  	u32 a0, a1;
> 
> Longest to shortest line for local variable declarations please.

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Kernel Security Engineering, Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635
