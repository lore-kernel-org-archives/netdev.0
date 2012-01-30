From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 30 Jan 2012 10:11:18 -0800
Message-ID: <CAL1RGDXjjQ-PhCv-9WJX45NuovC9XiS=_7507OsyvLW_gBaJ5g@mail.gmail.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
 <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
 <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com> <36F7E4A28C18BE4DB7C86058E7B607240BE9687A@MTRDAG01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <36F7E4A28C18BE4DB7C86058E7B607240BE9687A-SlGPd/IId7auSA5JZHE7gA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 29, 2012 at 11:44 PM, Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> I see this fix as part of a more general fix, one that will enable more protocols (e.g. X25, PPP) to enjoy the benefit of GRO.
> I think that the more general fix should include adding a MAC comparison function to the header_ops structure in netdev.h.
> Then network drivers which are not Ethernet will register their own comparison function, and the GRO code will check if such routine exists and if so will use it.
> The problem with this approach is that until such a major fix is integrated the IPoIB performance will suffer.
> This simple fix will enable us to use the benefit of GRO until the more general fix is integrated.

But is this general fix so difficult that we can't just do the right thing?

Realistically if we add this hack to ipoib then we'll have that ugly
memset in our fast path forever.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
