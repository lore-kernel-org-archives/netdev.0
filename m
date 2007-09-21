From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 14:27:11 -0700
Message-ID: <41b516cb0709211427s45cdd3b0pa0bb76d114d5f041@mail.gmail.com>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190375946.4261.42.camel@localhost>
	 <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost>
	 <1190382366.4231.13.camel@localhost>
	 <46F3E695.7010604@candelatech.com>
	 <1190409160.4231.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ben Greear" <greearb@candelatech.com>,
	"Emil Micek" <emil.micek@tkrjasek.cz>,
	"auke-jan.h.kok@intel.com" <auke-jan.h.kok@intel.com>,
	"netdev mailing list" <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:6880 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755372AbXIUV1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 17:27:13 -0400
Received: by fk-out-0910.google.com with SMTP id z23so905832fkz
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 14:27:11 -0700 (PDT)
In-Reply-To: <1190409160.4231.29.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/21/07, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2007-21-09 at 08:43 -0700, Ben Greear wrote:
>
> > I just re-read the spec, and a bridge *may* pad up to 68, but it is not
> > required.
> > On page 166, it says equipment must be able to handle 64 byte minimums.
> >
> > See page 22 (section 7.2) of this document:
> >
> > http://standards.ieee.org/getieee802/download/802.1Q-1998.pdf
> >
> > Also, page 63, 165, 166
>
> Thanks for the enlightnment.
> Do we need an ethtool interface to turn off hardware accelerated vlans?
> Jesse is indicating that the intel hardware can only handle the MUST but
> not the SHOULD of the spec.
> Actually a more basic question: Can you select one or the other mode in
> the software based vlans?

Inserting the VLAN tag in software will not change the behavior in the
way you want anyway, short frames will still be padded to 64 bytes.
You'd have to do short packet padding in software to 68 bytes.  Or do
software padding to 64 bytes and let the hardware insert the VLAN tag
after.

Chris
