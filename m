From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 2 Jan 2011 23:04:03 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1101022300220.11481@swampdragon.chaosbits.net>
References: <1293982286-15389-1-git-send-email-stefani@seibold.net>  <alpine.LNX.2.00.1101022024200.11481@swampdragon.chaosbits.net> <1294004772.5675.11.camel@wall-e>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294004772.5675.11.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Jan 2011, Stefani Seibold wrote:

> Am Sonntag, den 02.01.2011, 20:55 +0100 schrieb Jesper Juhl:
> > On Sun, 2 Jan 2011, stefani@seibold.net wrote:
> 
> 
> > > +
> > > +#define VERSION	"0.71"
> > 
> > I personally don't think this makes much sense.
> > Version numbers for individual modules tend to not get updated as the code 
> > changes over the years, which make them rather meaningless.
> > Since this module depends on functionallity of the kernel which it is 
> > compiled with, the actual (meaningful) version of this code is that of the 
> > kernel tree being compiled that includes this code. Which again makes this 
> > specific version define meaningless.
> > 
> > So, why not save a few lines of code and get rid of this rather pointless 
> > thing?
> > 
> 
> I like it, it gives me a better monitoring during development which
> version is currently tested.
> 
Does it really?  If your code is merged, then it's probably going to be
changed by various people over the years and not all of them (most) are
not going to notice nor change the version number, nor is the version
number here going to be changed when other parts of the kernel (that you
depend upon) are changed. So when you get a bug report in the future
mentioning VERSION xxx.yyy.zzz of your module it's not going to tell you
anything. What you want to know is the version of the kernel proper (or
git head commit id) - the VERSION defined here is likely going to be next
to useless in 1+ years (or less), so why have it at all?


> > [...]
> > > +static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
> > > +{
> > > +	struct udpcp_dest *dest;
> > > +
> > > +	dest = __find_dest(sk, addr, port);
> > 
> > Why not
> > 
> > static struct udpcp_dest *find_dest(struct sock *sk, __be32 addr, __be16 port)
> > {
> >      struct udpcp_dest *dest =  __find_dest(sk, addr, port);
> > 
> > ?
> I will fix it but i think this is counting peas.
>  
Sure, it's a tiny trivial thing. I just took the time to actually read
through your patch and then I commented on everything I spotted.


> > [...]
> > > +static void udpcp_flush_err(struct sock *sk, struct udpcp_dest *dest)
> > > +{
> > > +	struct inet_sock *inet = inet_sk(sk);
> > > +	struct udpcp_sock *usk = udpcp_sk(sk);
> > > +
> > > +	if (!inet->recverr)
> > > +		skb_queue_purge(&dest->xmit);
> > > +	else {
> > 
> > CodingStyle would want this as
> > 
> >      if (!inet->recverr) {
> >              skb_queue_purge(&dest->xmit);
> >      } else {
> > 
> > If one branch needs {} then both should get them.
> > 
> ./scripts/checkpatch.pl did not complain about this, so i think it is
> okay.
> 
scripts/checkpatch.pl is not the final judge on style issues - not by a 
long shot. In any case, if you read Documentation/CodingStyle you'll 
notice this : 

"
Do not unnecessarily use braces where a single statement will do.

if (condition)
        action();

This does not apply if one branch of a conditional statement is a single
statement. Use braces in both branches.

if (condition) {
        do_this();
        do_that();
} else {
        otherwise();
}
"


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.
