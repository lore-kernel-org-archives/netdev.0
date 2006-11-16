From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: bcm43xx regression 2.6.19rc3 -> rc5, rtnl_lock trouble?
Date: Thu, 16 Nov 2006 20:16:41 +0100
Message-ID: <200611162016.42095.mb@bu3sch.de>
References: <455B63EC.8070704@madrabbit.org> <455BFC47.3020006@madrabbit.org>
	<455CAB2F.1060709@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Ray Lee <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>
In-Reply-To: <455CAB2F.1060709-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 16 November 2006 19:17, Larry Finger wrote:
> Ray Lee wrote:
> > Larry Finger wrote:
> >> Ray Lee wrote:
> >>> Michael Buesch wrote:
> >>>> On Wednesday 15 November 2006 20:01, Ray Lee wrote:
> >>>>> Suggestions? Requests for <shudder> even more info?
> >>>> Yeah, enable bcm43xx debugging.
> >>> Sigh, didn't even think to look for that. Okay, enabled and compiling
> >>> a new kernel. This will take a few days to trigger, if the pattern holds, so
> >>> in the meantime, any *other* thoughts?
> >> Which chip and revision do you have? Send me your equivalent of the line
> >> "bcm43xx: Chip ID 0x4306, rev 0x2".
> > 
> > bcm43xx: Chip ID 0x4306, rev 0x3
> > 
> > Also, another thing I wasn't clear about in my first email was that the netdev
> > watchdog timeouts are new with rc5:
> > 
> > $ zgrep 'NETDEV WATCH' /var/log/messages{,.0,.1.gz} | cut -d: -f2| cut -c 1-6
> > | uniq -c
> >    1249 Nov 13
> >       6 Nov  6
> >       1 Nov  7
> >       3 Nov  8
> >       2 Nov  9
> >    5717 Nov 10
> >    5652 Nov 11
> >       5 Oct 29
> >       3 Oct 30
> >       3 Oct 31
> >       4 Nov  1
> >       1 Nov  2
> >       1 Nov  3
> > 
> > I booted into 2.6.19-rc5 on November 10th. Previous to that was 2.6.19-rc3.
> > There really does seem to be something suspicious with that patch, yes?
> > 
> > Thanks,
> > 
> > Ray
> > 
> 
> It certainly looks as if the "Drain TX status" patch is causing the problem; however, it should do 
> nothing for core revisions < 5, and yours is a 3.

You are looking at the wrong revision number.
You are looking at the chip revision, while this tests for the
802.11 core revision. Get the dmesg line which prints info for the
core with ID 0x812.

> Could you do me a favor? Please use git to download the current contents of Linus's tree with a "git 
> clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git new_dir". Using the same 
> .config as your current kernel and the git bisect command, you should be able to isolate the commit 
> that is causing the error. I know that it is a lot of work and will take considerable time; however, 
> that way we will see if some other change is triggering the problem.

Well, please bisect it anyway. Otherwise it will be very hard to track down.

-- 
Greetings Michael.
