From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Fri, 3 Oct 2003 23:59:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031004065925.GB94203@gaz.sfgoth.com>
References: <200310011134.h91BYPkT003172@ginger.cmf.nrl.navy.mil> <20031001054226.126cea7b.davem@redhat.com> <20031003022615.GA42593@gaz.sfgoth.com> <20031003065824.713627c6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031003065824.713627c6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Part of that is using the rtnl semaphore etc.

I've thought about this some more and I think we really DO want a
per-atm-device semaphore for this rather than overloading rtnl_sem.

A device like an ADSL card might need to do a complete physical-layer
negotiation when you open a VCC (assuming there were no VCCs open
before)  This could take on the order of a minute if it fails.  You
don't want to be hogging rtnl_sem for that long.

-Mitch
