From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: What were the reasons of having mandatory IP address at AX.25
	interfaces ?
Date: Mon, 4 Feb 2008 17:02:40 +0200
Message-ID: <20080204150240.GB2537@mea-ext.zmailer.org>
References: <S3540591AbYBCSQN/20080203181613Z+1592@mail.zmailer.org> <47A60A57.5080402@digitalrealm.net> <20080203202819.GX2537@mea-ext.zmailer.org> <20080204130252.GA2537@mea-ext.zmailer.org> <p731w7s4wic.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Received: (mea@mea-ext) by mail.zmailer.org id S3540486AbYBDPCk (ORCPT
	<rfc822;netdev@vger.kernel.org> + 1 other);
	Mon, 4 Feb 2008 17:02:40 +0200
Content-Disposition: inline
In-Reply-To: <p731w7s4wic.fsf@bingen.suse.de>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 04, 2008 at 03:38:35PM +0100, Andi Kleen wrote:
> Matti Aarnio <matti.aarnio@zmailer.org> writes:
> 
> > .. the original reason was apparently that _ifconfig_ blew up
> > when it saw protocols that it didn't understand on network
> > interfaces.  Possibly when there was no IP protocol on an
> > interface.
> 
> It's not only ifconfig, a lot of programs use SIOCGIFCONF
> to query ip addresses.

So ?   My codes do too, and filter away things they are not
interested in.  (When they specifically look for IP addresses.)

Of course I may be in minority by expecting the unexpected,
and handling such "weird" multiprotocol systems...


I found original explanation for that mandatoryness finally.
It was in order to silence bug reports in certain cases when
real fix would have been to really find all interfaces instead
of complaining.

In the end I used same trick that  ifconfig  tool uses to find
all interfaces, and filter away those that AX.25 subsystems
are not interested in - end of  "SIOCGIFCONF problems".


netdev:ish developemnt thing would be, that we ( = myself probably )
make SIOCGIFCONF to return those devices that have addresses
in the protocol family that the socket used for the query has.

For PF_INET we might return also PF_INET6 values to lessen
the spanish-inquisition -impact...

.. or do you know any who looks up interface IP addresses with
PF_FILE ( = AF_UNIX ) socket ?

What do the competitor systems B, S, and W do ?

> -Andi

/Matti Aarnio
