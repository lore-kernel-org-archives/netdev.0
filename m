From: jamal <hadi@cyberus.ca>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: 29 Mar 2005 18:13:38 -0500
Message-ID: <1112138018.1088.31.camel@jzny.localdomain>
References: <424346FE.20704@cs.wisc.edu>
	 <20050324233921.GZ14202@opteron.random>	<20050325034341.GV32638@waste.org>
	 <20050327035149.GD4053@g5.random> <20050327054831.GA15453@waste.org>
	 <1111905181.4753.15.camel@mylaptop>
	 <20050326224621.61f6d917.davem@davemloft.net>
	 <Pine.LNX.4.61.0503272245350.30885@chimarrao.boston.redhat.com>
	 <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de>  <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>  <4249D0CB.2030506@hp.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, open-iscsi@googlegroups.com,
        ksummit-2005-discuss@thunk.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4249D0CB.2030506@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 17:03, Rick Jones wrote:

> 
> Eventually the TCP will hit its RTX limit and punt the connection, freeing the 
> buffers kept for retransmission right?
> 

If i read correctly the people arguing for iscsi say thats not good
enough. But they may be having other issues too...

> > 
> > On a slightly related topic: is SCSI (not iscsi) considered a reliable
> > protocol?
> > If yes, why would you wanna run a reliable protocol inside another
> > reliable protocol (TCP)?
> 
> Isn't it better to consider TCP a protocol that provides reliable notice of 
> (presumed) failure rather than a "reliable protocol?"
> 

You could if the parameters are adequely set (i think).

If both are reliable protocols then they would both have the standard
features and parameters:

- transmit (for simplicty assume window of 1)

loop for X times
{
- compute next retransmit time, Y, using some algorithm
- wait for ACK
- timeout 
- retransmit
}

so parameters X and retransmit time is where the conflict is.
If TCP is eagerly retransmitting a lot of bandwidth could be
wasted. if SCSI has X as infinite even more interesting things
could happen.
In any case i have seen horror stories of what happened to people
who tried to encapsulate an already reliable protocol inside TCP in
order to ship it across the big bad internet. I am pretty sure some
knowledgeable people were involved in getting iscsi going so it cant be
that simple. It would seem preferable to use SCTP instead.

cheers,
jamal
