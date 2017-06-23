From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 00/12] nfp: add flower app with representors
Date: Thu, 22 Jun 2017 22:50:14 -0700
Message-ID: <20170622225014.59d673c6@cakuba.netronome.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
        <CAJ3xEMgPWdg8gnAuGgufuxeYt4qDKrs8g+LBgm3BBG9KHnjGsQ@mail.gmail.com>
        <20170620122417.0c60582e@cakuba.netronome.com>
        <CAJ3xEMjTLs0aDLY_zDerm8o0yPmJktzBDE2rJ=QwXQZeS1+qCg@mail.gmail.com>
        <20170621024238.021e1f77@cakuba.netronome.com>
        <CAJ3xEMhyOiQX_jTpD5zWKY0oNkBoU1jyG3SMTpA091O8TbrjLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:11189 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754529AbdFWFuV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 01:50:21 -0400
In-Reply-To: <CAJ3xEMhyOiQX_jTpD5zWKY0oNkBoU1jyG3SMTpA091O8TbrjLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jun 2017 17:28:25 +0300, Or Gerlitz wrote:
> On Wed, Jun 21, 2017 at 12:42 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> 
> > Let me try to describe it a bit more instead.  Sorry but I'm not great
> > at ASCII art at this level of complexity and while having to stay
> > within 80 chars ;)
> >
> > Driver communicates with the Management FW via a mailbox.
> >
> > Driver loads, it gets the Application FW from disk.  It pushes the
> > entire FW to the mailbox and tells the Management FW to load it.  At
> > this point the PCIe datapath is loaded and driver discovers what
> > other communication channels are available.
> >
> > Driver checks which FW is loaded and finds appropriate nfp_app callbacks
> > for that FW.  If the nfp_app requires control message channel it will
> > map the control message queue/vNIC.  Driver spawn netdevs for
> > data vNICs.  Flower nfp_app may upon init spawn physical port
> > representors (single NFP chip supports tens of ports so they are not
> > all guaranteed a full vNIC in many designs).  Whenever representor is
> > spawned Application FW is notified with a control message.
> >
> > When user enables SR-IOV nfp_app sriov callback will be invoked and
> > flower nfp_app will respond by spawning VF reprs.  First version of the
> > Flower APP targets only the switchdev mode.  We plan to add legacy mode
> > and automatically pre-populate the rules if there is user interest.
> > Although I personally hope that people interested in legacy SR-IOV will
> > use our simpler CoreNIC app FW...  Flower APP will initially come up in
> > switchdev mode, no rules installed, all traffic will simply end up at
> > representors.  
> 
> This is much clearer now, thanks for explaining that over. Will be happy
> if you can elaborate a bit on the automatic tables pre-population for
> legacy mode emulation, sounds interesting.

Oh, I just meant that if someone wants to switch between legacy and
switchdev mode without changing the app FW - driver could hide the
representors and populate MAC/VLAN forwarding rules to get the same
behaviour as "legacy" cards have.
