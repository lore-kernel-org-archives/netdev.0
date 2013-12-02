From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net 1/8] igb: Update queue reinit function to call dev_close
 when init of queues fails
Date: Mon, 2 Dec 2013 17:18:16 +0000
Message-ID: <1386004696.1516.15.camel@bwh-desktop.uk.level5networks.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1385624162-10116-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20131129.154757.2160926223289559260.davem@davemloft.net>
	 <9BBC4E0CF881AA4299206E2E1412B6264FA00871@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43880 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107Ab3LBRSU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 12:18:20 -0500
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6264FA00871@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-02 at 16:55 +0000, Wyborny, Carolyn wrote:
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Friday, November 29, 2013 12:48 PM
> > To: Kirsher, Jeffrey T
> > Cc: Wyborny, Carolyn; netdev@vger.kernel.org; gospo@redhat.com;
> > sassmann@redhat.com
> > Subject: Re: [net 1/8] igb: Update queue reinit function to call dev_close when
> > init of queues fails
> > 
> > From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > Date: Wed, 27 Nov 2013 23:35:55 -0800
> > 
> > > From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > >
> > > This patch adds a call to dev_close if the queue reinit fails in order
> > > to make clearer to the user that the device is down.
> > >
> > > Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> > > Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > 
> > This is a very bad approach to this problem.
> > 
> > Users absolutely do not expect their entire interface to go down simply because
> > an ethtool request cannot be satisfied.  This is extremely poor quality of
> > implementation.
> > 
> > And in this specific case it absolutely is not necessary.
> > 
> > The only thing that can fail is the queue allocation, so make a function which can
> > preserve the previous configuration if the queue allocation fails.  How about
> > "igb_reinit_interrupt_scheme".
> > 
> > Don't free the q vectors until the very last moment, when you know that the
> > allocation of the new q vectors has succeeded.
> > 
> > I'm not applying this patch, it needs to be reimplemented more sanely, using the
> > above suggestions or similar.
> > 
> 
> I did this per Ben's suggestion on Laura's original patch.  You didn't
> argue with it at the time.  I don't think I misunderstood his
> suggestion, but if so, I'll rework it.

My concerns were that after a failure where the interface is effectively
down,
- the interface must be in a consistent state where is it safe to
reconfigure the interface again or to unbind the driver, and
- it should be obviously down so the user can then try to bring it up
again.

David is saying that you should implement the reconfiguration in such a
way that you can always roll back to the previous working state in case
of a failure (which would make my concerns moot).  This is definitely a
good goal but I'm not convinced that it's always possible.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
