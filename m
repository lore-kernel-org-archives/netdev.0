From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: Unable to halt or reboot due to - unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
Date: Thu, 31 Aug 2006 17:33:15 +0200
Message-ID: <9a8748490608310833x22b0ca30s2130cc388e2bb392@mail.gmail.com>
References: <9a8748490608310817v7d722f88u167b5a84d0ff67e8@mail.gmail.com>
	 <44F70092.3030300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Mark Evans" <evansmp@uhura.aston.ac.uk>,
	"Fred N. van Kempen" <waltje@uwalt.nl.mugnet.org>,
	"Ross Biro" <ross.biro@gmail.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751654AbWHaPdS@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <44F70092.3030300@candelatech.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/08/06, Ben Greear <greearb@candelatech.com> wrote:
> Jesper Juhl wrote:
> > Hi,
> >
> > I've got a small problem with 2.6.18-rc5-git2.
> >
> > I've got a vlan setup on eth0.20, eth0 does not have an IP.
> >
> > When I attempt to reboot or halt the machine I get the following
> > message from the loop in net/core/dev.c::netdev_wait_allrefs() where
> > it waits for the ref-count to drop to zero.
> > Unfortunately the ref-count stays at 1 forever and the server never
> > gets any further.
> >
> >  unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
> >
> > I googled a bit and found that people have had similar problems in the
> > past and could work around them by shutting down the vlan interface
> > before the 'lo' interface. I tried that and indeed, it works.
> >
> > Any idea how we can get this fixed?
>
> This is usually a ref-count leak somewhere.  Used to be IPv6 had
> issues..then there were some neighbor leaks...but these were fixed as
> far as I know.
>
Using IPv4 here.


> Can you reproduce this on older kernels?
>
I've not actively tried, but I do have several servers running various
older kernel releases with similar vlan setups and I'm not aware of
any problems with those. Only this new box that I'm using for testing
new kernels (currently) shows the problem, and I've only tried 2.6.8
and 2.6.18-rc5-git2 on the box so far (2.6.8 doesn't have the
problem).

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
