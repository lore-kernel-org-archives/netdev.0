From: James Chapman <jchapman@katalix.com>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Tue, 21 Sep 2004 10:55:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095760525.414ffa8d111a1@www.katalix.com>
References: <1095714704.414f4790cd168@www.katalix.com> <20040920141704.16085067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, kleptog@svana.org, mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, bcrl@kvack.org
In-Reply-To: <20040920141704.16085067.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting "David S. Miller" <davem@davemloft.net>:

> On Mon, 20 Sep 2004 22:11:44 +0100
> James Chapman <jchapman@katalix.com> wrote:
>
> > Attached is a revised version of the new PPP over L2TP support for
> > review. Thanks DaveM and Herbert for comments so far. The following
> > comments have been addressed in this new version:
>
> What relation does your work have to the L2TP implementation
> being worked on by Ben LaHaise?  See:
>
> http://marc.theaimsgroup.com/?l=linux-netdev&m=109375044707414&w=2
>
> Do we have two people working on this thing. :-/
>
> Ben didn't post any pointers to his work so I couldn't do the
> comparison myself.
>

Ben and I are working on separate projects. I was unaware of his work
until I saw his netdev post a few weeks ago and mailed him privately to find
out more. He's using the old Babylon (Spellcaster) proprietary PPP
stack that has now been GPL'd.

Unfortunately I haven't seen Ben's code yet either so I can't give a
direct comparison. Ben? I did have a look at the Babylon stuff
(1.6-pre3), although I've no idea how much of it Ben has
changed. Here's a summary, fyi.

Babylon:-

- Architecture seems to be using char devices for communication with
  the kernel and all the PPP datapath is handled by custom virtual
  net_devices; the generic PPP kernel code isn't used as far as I can
  tell. Unfortunately it is very old (linux-2.0 era I think) but Ben
  has probably updated it.

- Some form of L2TP support is there but it is very basic. Userspace
  sends data through char devices (read()/write() which the kernel
  char driver converts to skbs and passes on. Nasty.

- PPP stack supports multiple PPP sessions in one daemon (unlike pppd).

- Unlikely to integrate with the new native IPSEC stuff.

OpenL2TP:-

- Communication with kernel is through a new PPPoL2TP socket family.
  There's one socket per L2TP session so MAX_FILES limits max
  sessions. Works with the new native IPSEC kernel code.

- Comprehensive userspace L2TP protocol implementation written from
  scratch, targetted specifically for enterprise VPN and embedded
  networking products. Efficient kernel datapath was deemed essential
  for this environment.

- Plugin architecture allows different PPP implementations to be used.
  Only pppd supported so far (limits max sessions still further due
  to process overhead) but I'm working on a daemon to support multiple
  sessions -- still early stages, evaluating alternatives. Babylon or
  hacking pppd or start again...

rp-l2tp:-

- No kernel datapath (all data copied into userspace through ptys).
  However, it could be modified to use the socket based kernel driver.

I think for general Linux L2TP support, a socket architecture makes
more sense. But maybe I'm biased... :)

If you want to find out more about OpenL2TP, checkout the
online man pages at http://openl2tp.sourceforge.net/.

BTW, I asked on linux-ppp if anyone was working on a single daemon PPP
to handle multiple sessions but got zero response.  Anyone on this
list know of any work in this area?

I hope this was useful.

/james
