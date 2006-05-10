From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Dscape ieee80211: enabling/disabling the radio
Date: Wed, 10 May 2006 16:10:17 +0200
Message-ID: <20060510161017.32f1e814@griffin.suse.cz>
References: <200605061401.01795.IvDoorn@gmail.com>
	<20060510124217.0d3810bd@griffin.suse.cz>
	<200605101553.52031.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Olivier <o.cornu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:44214 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751405AbWEJOKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 10:10:19 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605101553.52031.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 May 2006 15:53:48 +0200, Ivo van Doorn wrote:
> I think the problem is what the dscape exactly expects the driver to do when
> add_interface() is called by the stack. When that call has finished, does the stack
> expects the radio to be enabled, or should it instruct the driver to enable the radio later
> on through a field in the config structure.

At least for now, enabled if this is the first interface going up. Of
course, if a second (or so) interface is added, you shouldn't reenable
radio if it was disabled by previous config() call.

> But this might be resolved by demanding that the driver is keeping track of the number
> of interfaces added, and enabling the radio when at least 1 interface has been added
> and only disable the radio when all interfaces have been removed. And completely
> remove the open() and stop() handlers since they would only confuse matters.

Yes, this is the way it is supposed to work.

> Ah ok, I'll fix rt2x00 then to do the correct behaviour and no longer rely on open() and stop()
> for the radio, and add the counter for the number of interfaces that are up so the radio
> will behave in the correct fashion. :)

Please see http://www.spinics.net/lists/netdev/msg03975.html (and
following thread probably as well) for a description how to implement
this correctly.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
