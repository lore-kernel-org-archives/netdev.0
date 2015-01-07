From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] vxlan: Allow for VXLAN extensions to be implemented
Date: Wed, 7 Jan 2015 10:27:40 +0000
Message-ID: <20150107102740.GM21820@casper.infradead.org>
References: <cover.1420594925.git.tgraf@suug.ch>
 <7c5e8240263a22a69042c45a632c9940e5ae1062.1420594925.git.tgraf@suug.ch>
 <CA+mtBx_mp1mf_HPp5u9wDfgeOc8pt26Mf1VHFZTAqDhTdZe7cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:33043 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbAGK1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 05:27:42 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx_mp1mf_HPp5u9wDfgeOc8pt26Mf1VHFZTAqDhTdZe7cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/15 at 07:46pm, Tom Herbert wrote:
> On Tue, Jan 6, 2015 at 6:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > The VXLAN receive code is currently conservative in what it accepts and
> > will reject any frame that uses any of the reserved VXLAN protocol fields.
> > The VXLAN draft specifies that "reserved fields MUST be set to zero on
> > transmit and ignored on receive.".
> >
> IMO it is an unfortunate decision in VXLAN to ignore set reserved
> fields on receive. Had they not done this, then adding a protocol
> field to the header would have been feasible and we wouldn't need yet
> another encapsulation protocol (i.e. VXLAN-GPE). Rejecting frames with
> reserved bits set is the better behavior, but I think the comment
> about this needs to be clear about why this diverges from RFC7348.

Agreed. Do you want to give it a shot? I know you have been involved
on all aspects of this topic for a long time in NVO3 ;-)

> > Retain the current conservative parsing behaviour by default but allows
> > these fields to be used by VXLAN extensions which are explicitly enabled
> > on the VXLAN socket respectively VXLAN net_device.
> >
> Conceptually, VXLAN has both mandatory flags and optional flags for
> extensions. You may want to look at the VXLAN RCO patches that added
> an extension and infrastructure for them.

I've seen your proposed changes. I think they could be easily rebased
on top of this and use the enablement infrastructure. In fact, I see
this as the only feasible option to deal with VXLAN extensions: Leave
it to the user to decide which extensions to run. That way we can
support any combination of extensions, even conflicting ones. All we
have to do is catch incompatible extension configurations on a socket
and reject them at configuration time. Expecting that NVO3/IETF will
find consensus on a list of compatible set of extensions with perfect
forward and backwards compatibility is unrealistic in my eyes. We have
Geneve and GUE to solve it properly in the future.
