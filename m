From: Paul Furness <paul.furness@vil.ite.mee.com>
Subject: Re: NIS won't authenticate users
Date: 16 Apr 2002 13:33:24 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1018960404.1358.4.camel@x2.vil.ite.mee.com>
References: <Pine.LNX.4.44.0204112101100.8480-100000@junior.luna.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: dlt@lunanet.biz
In-Reply-To: <Pine.LNX.4.44.0204112101100.8480-100000@junior.luna.home>
List-Id: netdev.vger.kernel.org

Thanks. I did indeed check all these things, but it didn't help. In the
end I gave up and rebuilt the machine with RH 7.2 (ie not a beta) and it
worked more or less perfectly - the only trouble is that the servers
running the NIS are still running RH6.2, so only support 8 char
passwords, whereas the new setup supports longer passwords and doesn't
automatically truncate when you log in. All this means that I get
authenticated ok, but only if I type in the first 8 chars of my password
and no more.

<sigh> I'll just have to upgrade all the servers... :)

I should know by now that with beta releases, anything that looks like
it's probably alright probably isn't.

Paul

ps Sorry, I should have said thanks sooner!


On Fri, 2002-04-12 at 04:51, Donald Thompson wrote:
> Well, I'm not an NIS guru, but this is what I'd try...
> 
> You do have the line:
> +::0:0:::
> or something similar in /etc/passwd right? The line needs to have 1 less
> colons than are fields in your /etc/passwd file, which should be 7 fields.
> This line can look different depending upon what NIS users you want to
> allow onto the system. If its there, I'd still double and triple check
> by looking through Red Hat's docs that you've got it right.
> 
> Are you using md5 passwords? I've heard, but don't have first hand
> experience that enabling md5 passwords can cause problems with NIS.
> 
> Check /etc/nsswitch.conf, passwd and group should probably be set to
> 'compat'.
> 
> If that all fails, I'd check that its not a problem with the /bin/login
> thats on your system. Off hand the only thing that I know that doesn't use
> /bin/login is ssh (atleast not by default). So if you can get
> authenticated properly with ssh I'd say try replacing /bin/login. Just be
> careful if you do, since if you replace it with a version that for
> whatever reason doesn't work at all, it might become pretty difficult to
> get in.
> 
> -Don
> 
> On 11 Apr 2002, Paul Furness wrote:
> 
> > Hello, world.
> >
> > Is there by any chance a NIS guru around who can make some suggestions
> > about a problem I have?
> >
> > I have just built a linux workstation, and I want to join it to an
> > existing NIS domain for user authentication.
> >
> > Although it appears to bind correctly to the domain, and things like
> > ypwhich and getent produce exactly the results I want, it will not
> > accept a user's (correct) password. If I am on the box as root, and I su
> > - username, it works fine - so it obviously recognises the users. But if
> > I try and log in on the console as that user, I get an "Incorrect
> > Password" error.
> >
> > Interestingly, if I telnet to the box from anywhere and try logging in
> > as a NIS user, it says "User account has expired" and closes the
> > connection.
> >
> > I can log in fine a local user (this also works over telnet)
> >
> > I thought it might be the version of ypbind, so I tried updating that to
> > 3.3, with no effect.
> >
> > I know the existing domain is fine as all the other machines on the LAN
> > (about 50 or so) have no problems at all. I tried copying all the config
> > files that I think are important, but that didn't help either.
> >
> > One possible caveat: I'm trying out the beta of RedHat 7.3, but I don't
> > think that's the problem - all the rest of the networking seems stable
> > enough.
> >
> > I always thought I knew how to set up NIS, but this one is just not
> > working right!
> >
> > Anyone got any ideas?
> >
> > BUNgle.
> >
> > "If it ain't broke, hit it 'till it is, then you can fix it..."
> >
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-net" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


