From: "Gao Feng" <gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net] net: batman-adv: Fix possible
	memleaks when fail to register_netdevice
Date: Wed, 26 Apr 2017 08:41:30 +0800
Message-ID: <002901d2be25$d9092bd0$8b1b8370$@foxmail.com>
References: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com>
 <1756616.320MP6AHYH@bentobox>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, a@unstable.cc,
 'Gao Feng' <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: "'Sven Eckelmann'" <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>, <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1756616.320MP6AHYH@bentobox>
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
> Sent: Tuesday, April 25, 2017 9:53 PM
> On Dienstag, 25. April 2017 20:03:20 CEST gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org wrote:
> > From: Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
> >
> > Because the func batadv_softif_init_late allocate some resources and
> > it would be invoked in register_netdevice. So we need to invoke the
> > func batadv_softif_free instead of free_netdev to cleanup when fail to
> > register_netdevice.
> 
> I could be wrong, but shouldn't the destructor be replaced with
free_netdevice
> and the batadv_softif_free (without the free_netdev) used as ndo_uninit?
The
> line you've changed should then be kept as free_netdevice.
> 
> At least this seems to be important when using rtnl_newlink() instead of
the
> legacy sysfs netdev stuff from batman-adv. rtnl_newlink() would also only
call
> free_netdevice and thus also not run batadv_softif_free. This seems to be
only
> fixable by calling ndo_uninit.
> 
> Kind regards,
> 	Sven

Sorry, I don't get you.
The net_dev is created in this func batadv_softif_create.
Why couldn't invoke batadv_softif_free to cleanup when fail to
register_netdevice?

Best Regards
Feng
