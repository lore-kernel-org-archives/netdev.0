From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH][ATM]: [clip] fix race between modifying entry->vccs and clip_start_xmit()
Date: Mon, 15 Sep 2003 15:30:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915223048.GD92642@gaz.sfgoth.com>
References: <20030915225901.A22239@electric-eye.fr.zoreil.com> <200309152159.h8FLx1Sa005910@ginger.cmf.nrl.navy.mil> <20030915150217.06b03168.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams <chas@cmf.nrl.navy.mil>, romieu@fr.zoreil.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030915150217.06b03168.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> > which is always going to be in user context.  its a bit subtle but
> > there is no path to unlink_clip_vcc() that isnt in user context.
> 
> Are you really totally sure that no interrupt path can release
> a VCC?

That should be the case at least for any VCC on a real interface[*].
Some ATM cards have ->close() methods that can take a while so connection
teardown has to happen with some sort of sleepable context.  So if there
are cases where an interrupt causes the VCC to die they would need to be
fixed anyways.

-Mitch

[*] some protocols use psuedo-interfaces for their control connections - in
    theory I guess they could be different but I don't believe there are
    any cases where they are.  They wouldn't affect this issue anyways though.
