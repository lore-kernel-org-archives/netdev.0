From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Link detection
Date: Mon, 14 Mar 2005 17:54:28 +0100
Message-ID: <20050314165428.GR31837@postel.suug.ch>
References: <200503141435.38227.hasso@estpak.ee> <20050314133216.GM31837@postel.suug.ch> <200503141641.33510.hasso@estpak.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Hasso Tepper <hasso@estpak.ee>
Content-Disposition: inline
In-Reply-To: <200503141641.33510.hasso@estpak.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Hasso Tepper <200503141641.33510.hasso@estpak.ee> 2005-03-14 16:41
> > > 1) What's the proper way to detect carrier in Linux for user space
> > > application like Quagga?
> > >
> > > True, IFF_RUNNING is from BSD, but as long as the code in
> > > net/core/dev.c:dev_get_flags() is there, it gives nice clean way to get
> > > carrier status from user space (AFAIK it's used in same way in
> > > Solaris). Especially for applications using rtnetlink - ie. without it
> > > there is no all info in the netlink message any more. If these
> > > applications will receive RTM_NEWLINK, they have to poll kernel "look,
> > > maybe carrier status is changed" every time?

I've been looking into it more deeply. Sorry for the wrong information at first,
I thought IFF_RUNNING was unused after the link state was introduced, especially
after seeing IFF_RUNNING being ignored in iproue2 source. I'm fixing up the
drivers still doing it wrong, after that IFF_RUNNING should be accurate and with
no races. The way you're checking carrier at the moment is absolutely correct.
