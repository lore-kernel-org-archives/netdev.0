From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: After a while of system running no incoming UDP any more?
Date: Wed, 26 Jul 2017 10:33:04 +0200
Message-ID: <1501057984.4993.1.camel@redhat.com>
References: <20170724120901.6bpcieyvn5nccm2l@torres.zugschlus.de>
         <1500905950.2458.6.camel@redhat.com>
         <20170725115745.bbguoecrcsfhbm7f@torres.zugschlus.de>
         <1500985072.13149.4.camel@redhat.com>
         <20170726081047.562anntu5uhwirze@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751574AbdGZIdG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 04:33:06 -0400
In-Reply-To: <20170726081047.562anntu5uhwirze@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-07-26 at 10:10 +0200, Marc Haber wrote:
> On Tue, Jul 25, 2017 at 02:17:52PM +0200, Paolo Abeni wrote:
> > On Tue, 2017-07-25 at 13:57 +0200, Marc Haber wrote:
> > > On Mon, Jul 24, 2017 at 04:19:10PM +0200, Paolo Abeni wrote:
> > > > Once that a system enter the buggy status, do the packets reach the
> > > > relevant socket's queue?
> > > > 
> > > > ss -u
> > > 
> > > That one only shows table headers on an unaffected system in normal
> > > operation, right?
> > 
> > This one shows the current lenght of the socket receive queue (Recv-Q,
> > the first column). If the packets land into the skbuff (and the user
> > space reader for some reason is not woken up) such value will grow over
> > time.
> 
> Only that there is no value:
> [4/4992]mh@swivel:~ $ ss -u
> Recv-Q Send-Q Local Address:Port                 Peer Address:Port              
> [5/4992]mh@swivel:~ $
> 
> (is that the intended behavior on a system thiat is not affected by the
> issue?)

That means there are no open UDP connected sockets in the system at the
moment you  run ss -u. I forgot to specify you must add also the '-a'
command line option to the 'ss' tool to show all udp sockets regardless
theis state:

ss -ua

Anyway this issue looks quite similar to:

https://bugzilla.kernel.org/show_bug.cgi?id=196469

Which contains some more information. I suggest to follow-up on such
bz.

Cheers,

Paolo
