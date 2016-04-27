From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH 4/4] samples/bpf: allow make to be run from
 samples/bpf/ directory
Date: Wed, 27 Apr 2016 13:15:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4AB7FE@AcuExch.aculab.com>
References: <20160426110828.20716.13392.stgit@firesoul>
 <20160426110932.20716.51360.stgit@firesoul>
 <20160426143524.GB39797@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bblanco@plumgrid.com" <bblanco@plumgrid.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"linux-kbuild@vger.kernel.org" <linux-kbuild@vger.kernel.org>
To: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:51788 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbcD0NRX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 09:17:23 -0400
In-Reply-To: <20160426143524.GB39797@ast-mbp.thefacebook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov
> Sent: 26 April 2016 15:35
> On Tue, Apr 26, 2016 at 01:09:32PM +0200, Jesper Dangaard Brouer wrote:
> > It is not intuitive that 'make' must be run from the top level
> > directory with argument "samples/bpf/" to compile these eBPF samples.
> >
> > Introduce a kbuild make file trick that allow make to be run from the
> > "samples/bpf/" directory itself.  It basically change to the top level
> > directory and call "make samples/bpf/" with the "/" slash after the
> > directory name.
> >
> > Also add a clean target that only cleans this directory, by taking
> > advantage of the kbuild external module setting M=$PWD.
> >
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >  samples/bpf/Makefile   |    8 ++++++++
> >  samples/bpf/README.rst |    3 +++
> >  2 files changed, 11 insertions(+)
> >
> > diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> > index 7ac66f5bbbf5..7370dfee482f 100644
> > --- a/samples/bpf/Makefile
> > +++ b/samples/bpf/Makefile
> > @@ -85,6 +85,14 @@ HOSTLOADLIBES_test_overhead += -lelf -lrt
> >  #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
> >  LLC ?= llc
> >
> > +# Trick to allow make to be run from this directory
> > +all:
> > +	$(MAKE) -C ../../ $$PWD/
> > +
> > +clean:
> > +	$(MAKE) -C ../../ M=$$PWD clean
> > +	@rm -f *~
> > +
> 
> nice trick!

Another nice 'trick' is to write a GNUmakefie containing the local rules.
GNU make will read it in preference to Makefile and makefile.

	David
