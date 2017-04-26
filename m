From: "Gao Feng" <gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net] net: batman-adv: Fix possible
	memleaks when fail to register_netdevice
Date: Wed, 26 Apr 2017 15:28:26 +0800
Message-ID: <005501d2be5e$b2bb0550$18310ff0$@foxmail.com>
References: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com>
 <3994535.Z9kqCnttI2@bentobox> <002101d2be58$8bcaaa00$a35ffe00$@foxmail.com>
 <2857108.moq831zFsU@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, a@unstable.cc, 'Gao Feng' <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "'Sven Eckelmann'" <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <2857108.moq831zFsU@bentobox>
Content-Language: zh-cn
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

> From: Sven Eckelmann [mailto:sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org]
> Sent: Wednesday, April 26, 2017 3:17 PM
> On Mittwoch, 26. April 2017 14:44:24 CEST Gao Feng wrote:
> [...]
> > I get it now, thanks.
> [...]
> > BTW, I think although the batadv_softif_create is legacy, we should
> > fix it when it still exists :)
> 
> I didn't meant that we should not fix it. I just said that it looks to me
like the fix
> should look different to ensure that it actually fixes the sysfs and rtnl
link
> implementation for the batadv interface creation. Right now the ndo_uninit
> (when it would be set by batadv) is called in the netdev core functions
when an
> error happens during the registration. This is not the case for the
destructor.

Thanks your answer.
I assumed the destructor is not for this case before.. 

> Your patch would not change it. It therefore looks like you simply have to
move
> the current destructor (without the free_netdev) to ndo_uninit and change
the
> destructor to free_netdev.

Yes, that patch didn't touch badman-adv. Because current badman-adv doesn't
support newlink now.
It would be good that cleanup the resource in ndo_uninit routine.

Best Regards
Feng
 
> 
> The batadv ops doesn't have a newlink function. It will therefore use the
> register_netdevice code path which calls free_netdev on failures. The
extra
> cleanup you've added in
> https://www.mail-archive.com/netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org/msg165253.html can
> therefore not work for batman-adv. Actually, it is not touching anything
> batman-adv related. The suggestion to change the register_netdevice ->
> free_netdev part in rtnl_newlink was new in the reply to the batadv
discussion.
> It is therefore still an open discussion how it is correctly fixed.
> 
> Kind regards,
> 	Sven
