From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: Link detection
Date: Mon, 14 Mar 2005 16:41:33 +0200
Message-ID: <200503141641.33510.hasso@estpak.ee>
References: <200503141435.38227.hasso@estpak.ee> <20050314133216.GM31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050314133216.GM31837@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Hasso Tepper <200503141435.38227.hasso@estpak.ee> 2005-03-14 14:35
>
> > 1) What's the proper way to detect carrier in Linux for user space
> > application like Quagga?
> >
> > True, IFF_RUNNING is from BSD, but as long as the code in
> > net/core/dev.c:dev_get_flags() is there, it gives nice clean way to get
> > carrier status from user space (AFAIK it's used in same way in
> > Solaris). Especially for applications using rtnetlink - ie. without it
> > there is no all info in the netlink message any more. If these
> > applications will receive RTM_NEWLINK, they have to poll kernel "look,
> > maybe carrier status is changed" every time?
>
> You should open a rtnetlink socket and register to the RTMGRP_LINK
> multicast group and filter for RTM_NEWLINK with ifi_change & IFF_UP and
> then look at ifi_flags & IFF_UP to see whether the interface is now
> up or down. You'll receive such a rtnetlink message everytime the
> carrier status changes.

Forgot to answer this part. We already do all this. IFF_UP doesn't show 
carrier status, but administrative status. IFF_RUNNING shows carrier 
status.


with my best wishes,

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
