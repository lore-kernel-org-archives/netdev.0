From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [PATCH] RFKILL: fix input layer initialisation
Date: Mon, 23 Jun 2008 15:21:42 -0300
Message-ID: <20080623182141.GD22039@khazad-dum.debian.net>
References: <20080619112841.GA12051@doriath.ww600.siemens.net> <20080623091714.ZZRA012@mailhub.coreip.homeip.net> <20080623144024.GD8606@doriath.ww600.siemens.net> <20080623112226.ZZRA012@mailhub.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>, IvDoorn@gmail.com
To: Dmitry Baryshkov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3.smtp.messagingengine.com ([66.111.4.27]:57004 "EHLO
	out3.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754291AbYFWSVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 14:21:50 -0400
Content-Disposition: inline
In-Reply-To: <20080623112226.ZZRA012@mailhub.coreip.homeip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Jun 2008, Dmitry Torokhov wrote:
> On Mon, Jun 23, 2008 at 06:40:24PM +0400, Dmitry Baryshkov wrote:
> > On Mon, Jun 23, 2008 at 09:22:39AM -0400, Dmitry Torokhov wrote:
> > > Hi Dmitry,
> > > 
> > > On Thu, Jun 19, 2008 at 03:28:41PM +0400, Dmitry Baryshkov wrote:
> > > > Initialise correctly last fields, so tasks can be actually executed
> > > > 
> > > > Also move rfkill-input initialisation to subsys level so that it's
> > > > available before generic drivers probing occurs.
> > > > 
> > > 
> > > Rfkill-input is an implementation of default policy of handling
> > > wifi-related key presses, it is not mandatory and should not be
> > > required for a driver to operate, it may even not be present in the
> > > kernel and therefore module_init is the appropriate time for its
> > > initialization. We don't expect user to start pushing WIFI buttons
> > > while system just starting to boot up, do we?
> > 
> > I do toggle the KEY_BLUETOOTH from the kernel driver early.
> > The preliminary patch can be found at
> > http://permalink.gmane.org/gmane.linux.ports.arm.kernel/43136
> > 
> > The idea was to drive the bluetooth chip attached to the UART from the
> > uart pm hook.
> 
> Is there an actual button there? If not you should not create input
> device. You probably need to talk to Henrique (CCed) about how
> properly integrate rfkill support.

I'd be glad to help.  Torokhov got me in the loop because of an ongoing
rfkill enhancement and documentation enfort I am pushing for, that is being
fleshed out in linux-wireless.

Please describe to me *what* your driver needs to do.  As Torokhov said, it
is very weird that it would need rfkill-input for anything.  I know of no
valid use case to issue KEY_* input events except if you are a driver for
something that has a button/key that was pressed (i.e. a driver for an input
device)... and rfkill-input doesn't matter at all for these.

If your driver is issuing KEY_BLUETOOTH to sync state, that's a layering
violation, and lot allowed.  I may be able to help you fix it through the
patches being reviewed in linux-wireless.

If it is something else, I will try to help, but I need to understand the
details of what your driver is trying to accomplish, first.

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
