From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [RFC v3 02/10] Revert "lsm: Remove the socket_post_accept() hook"
Date: Fri, 6 May 2011 06:43:42 +0900
Message-ID: <201105060643.JBD90633.MOQJtSFFLFHOOV@I-love.SAKURA.ne.jp>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
	<201105031802.34724.paul.moore@hp.com>
	<201105041128.BAB13061.LMHVtOSOQOFFJF@I-love.SAKURA.ne.jp>
	<201105051011.32845.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, root@localdomain.pl
To: paul.moore@hp.com, sam@synack.fr
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201105051011.32845.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Moore wrote:
> On Tuesday, May 03, 2011 10:28:24 PM Tetsuo Handa wrote:
> > Paul Moore wrote:
> > > On Tuesday, May 03, 2011 10:24:15 AM Samir Bellabes wrote:
> > > > snet needs to reintroduce this hook, as it was designed to be: a hook
> > > > for updating security informations on objects.
> > > 
> > > Looking at this and 5/10 again, it seems that you should be able to do
> > > what you need with the sock_graft() hook.  Am I missing something?
> > > 
> > > My apologies if we've already discussed this approach previously ...
> > 
> > Second problem is that genlmsg_unicast() might return -EAGAIN because we
> > can't sleep inside write_lock_bh()/write_unlock_bh().
> 
> Ah yes, the real problem.  I forgot that snet relied on a user space tool.  I 
> tend to agree with others who have suggested this is not the right approach, 
> but I understand why you want the post_accept() hook; thanks for reminding me.
> 
However, it sounds that Samir says genlmsg_unicast() failure is not fatal.

Samir Bellabes wrote:
> using snet_do_send_event() means that system is sending data to
> userspace. the system is not waiting for a verdict from userspace.
> 
> If error occurs, we actually loose the information data.
> I may be able to write a solution which try to send the data again, but
> we need a exit solution for this loop (a number of try ?).

If genlmsg_unicast() failure is not fatal, snet doesn't need the
socket_post_accept hook. Samir, is genlmsg_unicast() failure fatal for snet?
(Although, I'd like to ask for revival of the hook for TOMOYO anyway.)
