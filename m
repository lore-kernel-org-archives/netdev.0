From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 2/2] ip_tunnel: Add fallback tunnels to the hash lists
Date: Fri, 27 Sep 2013 09:56:54 +0200
Message-ID: <20130927075654.GE7660@secunet.com>
References: <20130925055418.GV7660@secunet.com>
 <20130925055519.GW7660@secunet.com>
 <CALnjE+rrm3Vzov4sUjBfEKHwzRb6MfTRhkA_B96yuNGpgFgiCg@mail.gmail.com>
 <20130926081344.GA7660@secunet.com>
 <CALnjE+pu6CEwB+p3TNH56N09Cwabr9QbaKotKiwbfyLvZUsSpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39063 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852Ab3I0H5B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 03:57:01 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+pu6CEwB+p3TNH56N09Cwabr9QbaKotKiwbfyLvZUsSpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 11:24:07AM -0700, Pravin Shelar wrote:
> On Thu, Sep 26, 2013 at 1:13 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > On Wed, Sep 25, 2013 at 09:03:11AM -0700, Pravin Shelar wrote:
> >> fallback tunnel s not required to be in hash table, Its is returned if
> >> none of hashed tunnels are matched, ref ip_tunnel_lookup().
> >> Can you post command to reproduce this issue?
> >>
> >
> > Something like
> >
> > ip tunnel change tunl0 mode ipip remote 0.0.0.0 local 0.0.0.0 ttl 0 tos 1
> >
> > worked until v3.9 and stopped working with v3.10.
> 
> OK, I see the bug, tunnel exact match lookup does not check fb tunnel.
> There are two options.
> 1. Fix ip_tunnel_find() to check for fb tunnel.
> 2. Add fb tunnel to hash table, which is what ur patch does.
> I think your patch is better solution as it get rid of special case.
> But patch is not complete. It needs to remove fb tunnel checks on
> netdev unregister.

It looks like this is another bug that requires an additional patch.
We add the fallback tunnel to the unregister list when we iterate over
all netdevices in the namespace at the beginning of ip_tunnel_destroy()
and then again explicitly at the end of ip_tunnel_destroy().
