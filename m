From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 0/3] ethtool: support for forward error
 correction mode setting on a link
Date: Thu, 5 Oct 2017 11:30:55 -0700
Message-ID: <20171005113055.477aec34@cakuba.netronome.com>
References: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
        <20170727193320.308e86c3@cakuba.netronome.com>
        <CAJieiUiXuN9s0ndJ4K6UVE2pomRi0aD9PH6uYHe12qCzL0+wSg@mail.gmail.com>
        <20170728094620.525ba156@cakuba.netronome.com>
        <CAJieiUgM=t0GhnRXP5YYAZytFoKYRutpM0ZiVsDMjrpLZwCHsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Vidya Sagar Ravipati <vidya.chowdary@gmail.com>,
        Dustin Byford <dustin@cumulusnetworks.com>,
        Dave Olson <olson@cumulusnetworks.com>,
        Casey Leedom <leedom@chelsio.com>,
        Gal Pressman <galp@mellanox.com>, Andrew Lunn <andrew@lunn.ch>,
        Manoj Malviya <manojmalviya@chelsio.com>,
        Santosh Rastapur <santosh@chelsio.com>, yuval.mintz@qlogic.com,
        odedw@mellanox.com, Ariel Almog <ariela@mellanox.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Dirk van der Merwe <dirk.vandermerwe@netronome.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:31111 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751286AbdJESbH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 14:31:07 -0400
In-Reply-To: <CAJieiUgM=t0GhnRXP5YYAZytFoKYRutpM0ZiVsDMjrpLZwCHsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Jul 2017 23:28:26 -0700, Roopa Prabhu wrote:
> On Fri, Jul 28, 2017 at 9:46 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > On Fri, 28 Jul 2017 07:53:01 -0700, Roopa Prabhu wrote:  
> >> On Thu, Jul 27, 2017 at 7:33 PM, Jakub Kicinski <kubakici@wp.pl> wrote:  
> >> > On Thu, 27 Jul 2017 16:47:25 -0700, Roopa Prabhu wrote:  
> >> >> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> >> >>
> >> >> Forward Error Correction (FEC) modes i.e Base-R
> >> >> and Reed-Solomon modes are introduced in 25G/40G/100G standards
> >> >> for providing good BER at high speeds. Various networking devices
> >> >> which support 25G/40G/100G provides ability to manage supported FEC
> >> >> modes and the lack of FEC encoding control and reporting today is a
> >> >> source for interoperability issues for many vendors.
> >> >> FEC capability as well as specific FEC mode i.e. Base-R
> >> >> or RS modes can be requested or advertised through bits D44:47 of base link
> >> >> codeword.
> >> >>
> >> >> This patch set intends to provide option under ethtool to manage and
> >> >> report FEC encoding settings for networking devices as per IEEE 802.3
> >> >> bj, bm and by specs.
> >> >>
> >> >> v2 :
> >> >>         - minor patch format fixes and typos pointed out by Andrew
> >> >>         - there was a pending discussion on the use of 'auto' vs
> >> >>           'automatic' for fec settings. I have left it as 'auto'
> >> >>           because in most cases today auto is used in place of
> >> >>           automatic to represent automatically generated values.
> >> >>           We use it in other networking config too. I would prefer
> >> >>           leaving it as auto.  
> >> >
> >> > On the subject of resetting the values when module is replugged I
> >> > assume what was previously described remains:
> >> >  - we always allow users to set the FEC regardless of the module type;
> >> >  - if user set an incorrect FEC for the module type (or module gets
> >> >    swapped) the link will be administratively taken down by either
> >> >    the driver or FW.
> >> >
> >> > Is that correct?  Am I misremembering?  
> >>
> >> yes, correct. And possible future sfp hotplug events can give user-space
> >> more info to react to module type changes etc.  
> >
> > OK, if nobody else objects and we go with that - lets make sure we
> > document clearly those are expected :)  My concern is that if there is
> > ever 10G + RS FEC standard we don't want to end up in a situation where
> > some drivers silently ignore FEC settings in 10G and other apply it.
> > So let's make it clear what the intended Linux behaviour is.  It could
> > be in the ethtool man page, or the kernel somewhere.  
> 
> sure :), ack. We will document it in the ethtool manpage.

Hi Roopa!  Did you ever publish the ethtool user space patches at all?
I can't find them...
