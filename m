From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 1/3] Use C99 style initializers everywhere
Date: Sat, 18 Jun 2016 02:02:21 +0200
Message-ID: <20160618000221.GA10428@orbyte.nwl.cc>
References: <41801a15-fd99-6916-211c-705b4445023d@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"julien.floret@6wind.com" <julien.floret@6wind.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Stephen Hemminger <shemming@brocade.com>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38113 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbcFRACZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 20:02:25 -0400
Content-Disposition: inline
In-Reply-To: <41801a15-fd99-6916-211c-705b4445023d@cumulusnetworks.com>
 <20160617115753.6205562d@xeon-e3>
 <576420B0.3050203@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

[Replying to multiple mails at once due to laziness.]

On Fri, Jun 17, 2016 at 06:09:20PM +0200, Daniel Borkmann wrote:
> Hmm, seems like a lot of stuff ...

It is. At some point I thought about maybe hack something in cocci
instead, but that would probably have taken longer given the code
diversity. :/

I know this is crap to review, but splitting it up into a 100 patches
doesn't make much sense, either.

> Please have a look at commit 8f80d450c3cb ("tc: fix compilation with old gcc (< 4.6)") ...
> 
> Your changes effectively revert them again. Here, and some other parts of the bpf frontend
> code bits.

Oh, good catch! Thanks a lot for pointing this out. It definitely needs
to be sorted prior to applying my mess.


On Fri, Jun 17, 2016 at 11:57:53AM -0700, Stephen Hemminger wrote:
> It makes sense that if you can build a kernel with old toolchain, that
> iproute2 needs to be buildable as well.
> 
> The current kernels are documented to require 3.2 or later.

So in your opinion we should stay compatible to gcc-3.2? Clarifying
requirements like this one would make sense in order to know what to
check against.


On Fri, Jun 17, 2016 at 02:47:51PM -0600, David Ahern wrote:
> On 6/17/16 2:36 PM, Daniel Borkmann wrote:
[...]
> > I just pointed to the fact that this would basically undo their changes
> > that they've submitted some time ago to the BPF frontend, reintroducing
> > the issue for them. Unfortunately, the anonymous struct cannot be named
> > due to uapi reasons. It should have been named from the very beginning,
> > but unfortunately too late now. So I would suggest to just leave those
> > affected parts as is.
> 
> I was referring to Phil's patch. All of the struct {} req; 
> initializations should be fine if you name the structs, but then need to 
> run it through whatever compiler version the 6wind folks care about to 
> verify that is true.

I'm not so sure about that. What I did regarding the anonymous struct
req is not new in iproute2 code base: There is the GENL_REQUEST macro
which expands to an identical construct and it's there since end of
2012.

Commit 8f80d450c3cb changes only the initializers of union bpf_attr, so
maybe the problem is limited to anonymous structs in unions? Anyway, I
guess defining which minimum gcc version to depend on and testing
against it is the only real solution here.

Thanks, Phil
