From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: Unable to halt or reboot due to - unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
Date: Fri, 1 Sep 2006 11:59:44 +0200
Message-ID: <9a8748490609010259l7c42ca88tbcc87410a770b48c@mail.gmail.com>
References: <9a8748490608310817v7d722f88u167b5a84d0ff67e8@mail.gmail.com>
	 <44F70092.3030300@candelatech.com>
	 <9a8748490608310833x22b0ca30s2130cc388e2bb392@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Fred N. van Kempen" <waltje@uwalt.nl.mugnet.org>,
	"Ross Biro" <ross.biro@gmail.com>, davem@davemloft.net,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:20079 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751382AbWIAJ7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 05:59:45 -0400
Received: by wx-out-0506.google.com with SMTP id s14so944245wxc
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2006 02:59:45 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <9a8748490608310833x22b0ca30s2130cc388e2bb392@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/08/06, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> On 31/08/06, Ben Greear <greearb@candelatech.com> wrote:
> > Jesper Juhl wrote:
> > > Hi,
> > >
> > > I've got a small problem with 2.6.18-rc5-git2.
> > >
> > > I've got a vlan setup on eth0.20, eth0 does not have an IP.
> > >
> > > When I attempt to reboot or halt the machine I get the following
> > > message from the loop in net/core/dev.c::netdev_wait_allrefs() where
> > > it waits for the ref-count to drop to zero.
> > > Unfortunately the ref-count stays at 1 forever and the server never
> > > gets any further.
> > >
> > >  unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
> > >
> > > I googled a bit and found that people have had similar problems in the
> > > past and could work around them by shutting down the vlan interface
> > > before the 'lo' interface. I tried that and indeed, it works.
> > >
> > > Any idea how we can get this fixed?
> >
> > This is usually a ref-count leak somewhere.  Used to be IPv6 had
> > issues..then there were some neighbor leaks...but these were fixed as
> > far as I know.
> >
> Using IPv4 here.
>
>
> > Can you reproduce this on older kernels?
> >
> I've not actively tried, but I do have several servers running various
> older kernel releases with similar vlan setups and I'm not aware of
> any problems with those. Only this new box that I'm using for testing
> new kernels (currently) shows the problem, and I've only tried 2.6.8
> and 2.6.18-rc5-git2 on the box so far (2.6.8 doesn't have the
> problem).
>
I've just encountered the problem on a different server with an
identical vlan setup. That server is running 2.6.13.4

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
