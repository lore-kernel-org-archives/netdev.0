From: Donald Thompson <dlt@lunanet.biz>
Subject: Re: NIS won't authenticate users
Date: Thu, 11 Apr 2002 21:51:29 -0600 (MDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0204112101100.8480-100000@junior.luna.home>
References: <1018540696.32508.16.camel@x2.vil.ite.mee.com>
Reply-To: dlt@lunanet.biz
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
In-Reply-To: <1018540696.32508.16.camel@x2.vil.ite.mee.com>
List-Id: netdev.vger.kernel.org

Well, I'm not an NIS guru, but this is what I'd try...

You do have the line:
+::0:0:::
or something similar in /etc/passwd right? The line needs to have 1 less
colons than are fields in your /etc/passwd file, which should be 7 fields.
This line can look different depending upon what NIS users you want to
allow onto the system. If its there, I'd still double and triple check
by looking through Red Hat's docs that you've got it right.

Are you using md5 passwords? I've heard, but don't have first hand
experience that enabling md5 passwords can cause problems with NIS.

Check /etc/nsswitch.conf, passwd and group should probably be set to
'compat'.

If that all fails, I'd check that its not a problem with the /bin/login
thats on your system. Off hand the only thing that I know that doesn't use
/bin/login is ssh (atleast not by default). So if you can get
authenticated properly with ssh I'd say try replacing /bin/login. Just be
careful if you do, since if you replace it with a version that for
whatever reason doesn't work at all, it might become pretty difficult to
get in.

-Don

On 11 Apr 2002, Paul Furness wrote:

> Hello, world.
>
> Is there by any chance a NIS guru around who can make some suggestions
> about a problem I have?
>
> I have just built a linux workstation, and I want to join it to an
> existing NIS domain for user authentication.
>
> Although it appears to bind correctly to the domain, and things like
> ypwhich and getent produce exactly the results I want, it will not
> accept a user's (correct) password. If I am on the box as root, and I su
> - username, it works fine - so it obviously recognises the users. But if
> I try and log in on the console as that user, I get an "Incorrect
> Password" error.
>
> Interestingly, if I telnet to the box from anywhere and try logging in
> as a NIS user, it says "User account has expired" and closes the
> connection.
>
> I can log in fine a local user (this also works over telnet)
>
> I thought it might be the version of ypbind, so I tried updating that to
> 3.3, with no effect.
>
> I know the existing domain is fine as all the other machines on the LAN
> (about 50 or so) have no problems at all. I tried copying all the config
> files that I think are important, but that didn't help either.
>
> One possible caveat: I'm trying out the beta of RedHat 7.3, but I don't
> think that's the problem - all the rest of the networking seems stable
> enough.
>
> I always thought I knew how to set up NIS, but this one is just not
> working right!
>
> Anyone got any ideas?
>
> BUNgle.
>
> "If it ain't broke, hit it 'till it is, then you can fix it..."
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


