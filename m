From: Alex Tsariounov <alext@novell.com>
Subject: Re: [Alacrityvm-devel] configfs/sysfs
Date: Wed, 19 Aug 2009 17:48:17 -0600
Message-ID: <1250725697.6047.27.camel@zuul.thistledown>
References: <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu>
	 <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com>
	 <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com>
	 <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com>
	 <1250706227.27590.156.camel@haakon2.linux-iscsi.org>
	 <4A8C5CBB.10605@redhat.com>  <20090819221654.GA29503@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	alacrityvm-devel@lists.sourceforge.net,
	Anthony Liguori <anthony@codemonkey.ws>,
	Ingo Molnar <mingo@elte.hu>
To: Joel Becker <Joel.Becker@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charybdis-ext.suse.de ([195.135.221.2]:44809 "EHLO
	emea5-mh.id5.novell.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752243AbZHTAIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 20:08:42 -0400
In-Reply-To: <20090819221654.GA29503@mail.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 15:16 -0700, Joel Becker wrote:
> On Wed, Aug 19, 2009 at 11:12:43PM +0300, Avi Kivity wrote:
> > On 08/19/2009 09:23 PM, Nicholas A. Bellinger wrote:
> > >Anyways, I was wondering if you might be interesting in sharing your
> > >concerns wrt to configfs (conigfs maintainer CC'ed), at some point..?
> > 
> > My concerns aren't specifically with configfs, but with all the text
> > based pseudo filesystems that the kernel exposes.
> 
> 	Phew!  It's not just me :-)

The points on *fs vs. ioctl are interesting.  I think both have their
benefits and both have the downfalls, for example efficiency vs. ease of
(human) use. I suppose it comes down to whether you're in the fast path
or not for the most part.  However, just because and interface is not as
efficient as it can be does not necessarily mean that it's not a good
one.

As as an example, many moons ago, I worked on implementing some serial
comms between an embedded speed controller and its command console.
Being young and efficiency starved ;) I disregarded our other
controllers which implemented these serial comms with ASCII strings, and
used binary blobs instead.  I indeed got some respectable performance
out of doing this, even to the effect of creating a "real time" status
monitor that updated multiple times a second via the hand-held terminal.

However, I totally missed the point of intentionally doing things
"inefficiently."  For example, our serial debugging setup consisted of
two VT100 terminals wired up with a custom serial cable that went
between two communicating units.  Each term would show what each end was
saying.  Kinda crude, but effective.  Of course with my new and improved
controller that "spoke the binary language of moisture evaporators,"
well, all one saw was garbage.  :)

Additionally, someone debugging the controllers could just use a term to
talk to it if it used simple ASCII commands and take terminals, hosts
and other software out of the picture, but for my controller, well, you
could only use the custom programmed hand-held term.

I ended up supporting both ASCII and binary communications on the
controller for these (and other) reasons.  However, in the end, I
ditched the binary comms since they really didn't add the efficiency in
the fast path where it should be added.  (Well, I also ran out of eprom
space... :)

In any case, having a humanly understandable communications protocol (or
ABI) can be extremely useful, and just because it's not efficient
doesn't automatically mean that it's a bad thing, especially if it's in
the slow path.  It does have it's down sides as mentioned in this
thread, so we really need both types.  Because of that, the fuse layer
on top of a binary ABI is an interesting idea.

Alex

