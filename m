From: Paul Mackerras <paulus@samba.org>
Subject: Re: [Patch] fix packet loss and massive ping spikes with PPP
 multi-link
Date: Sat, 29 May 2010 12:16:24 +1000
Message-ID: <20100529021624.GA2538@brick.ozlabs.ibm.com>
References: <2d460de71003260850x7f90d04cy79ac853464108182@mail.gmail.com>
 <20100326160226.0159ac3b@lxorguk.ukuu.org.uk>
 <4BACE827.4070006@gmail.com>
 <20100326170428.6c1ad66c@lxorguk.ukuu.org.uk>
 <4BB31E00.8060204@netservers.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Alexander E. Patrakov" <patrakov@gmail.com>,
	Richard Hartmann <richih.mailinglist@gmail.com>,
	linux-kernel@vger.kernel.org
To: Ben McKeegan <ben@netservers.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4BB31E00.8060204@netservers.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2010 at 11:03:44AM +0100, Ben McKeegan wrote:

> I needed to do something similar a while back and I took a very
> different approach, which I think is more flexible.   Rather than
> implement a new round-robin scheduler I simply introduced a target
> minimum fragment size into the fragment size calculation, as a per
> bundle parameter that can be configured via a new ioctl.  This
> modifies the algorithm so that it tries to limit the number of
> fragments such that each fragment is at least the minimum size.  If
> the minimum size is greater than the packet size it will not be
> fragmented all but will instead just get sent down the next
> available channel.
> 
> A pppd plugin generates the ioctl call allowing this to be tweaked
> per connection.  It is more flexible in that you can still have the
> larger packets fragmented if you wish.

I like this a lot better than the other proposed patch.  It adds less
code because it uses the fact that ppp_mp_explode() already has a
round-robin capability using the ppp->nxchan field, plus it provides a
way to control it per bundle via pppd.

If you fix up the indentation issues (2-space indent in some of the
added code -- if you're using emacs, set c-basic-offset to 8), I'll
ack it and hopefully DaveM will pick it up.

Paul.
