From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: action stats double dip
Date: 25 Mar 2005 16:39:13 -0500
Message-ID: <1111786752.1090.678.camel@jzny.localdomain>
References: <1111767913.1091.530.camel@jzny.localdomain>
	 <1111768884.1092.533.camel@jzny.localdomain>
	 <20050325200650.GC3086@postel.suug.ch>
	 <1111782325.1089.641.camel@jzny.localdomain>
	 <20050325204110.GF3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050325204110.GF3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 15:41, Thomas Graf wrote:
> * jamal <1111782325.1089.641.camel@jzny.localdomain> 2005-03-25 15:25

> > tcf_exts_dump (called above the those calls) already dumps stats if you
> > are not in old compatibility mode. It doesnt when you are in old compat
> > mode. 
> > You could probably play tricks to move things into it; 
> > The main exception would be cls_u32 where you need to check
> > TC_U32_KEY(n->handle) and old compatibility;
> 
> Right, I had to leave it splitted for u32 but there are still
> issues. With your changes, the old policer will not get its stats
> dumped anymore.

My worry is this was always the case. 

>  Any reason for keeping the old policer alive? or
> can we purge it and make everyone use the compatibility police
> action? 

Well, old tc binaries exist and should continue to work. I suppose
we can put a time limit on how long such things can be supported.
It could get killed if it becomes a nuisance but it will have to be
advertised in some kernel changelogs 

>  Don't waste any time on this, it's my fault so let me
> resolve this.

I dont think that its devasting actually after i moved around 
the TCA_ACT_STAT attribute in previous patch (so even without that
fix all that would happen is tb[TCA_ACT_STATS] will be written twice.
And i dont think its your fault - bugs are expected(note my wisecrack
comments to Andy Furniss;->) and the patch was widely discussed none of
us saw this. 
Dave has already taken in the patch - if you want to amend things
i would suggest you do it against the patch i posted.

cheers,
jamal
