From: jamal <hadi@cyberus.ca>
Subject: Re: QoS _put, _get and _delete class ops semantic
Date: Thu, 11 Apr 2002 10:42:56 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204111039490.1224-100000@shell.cyberus.ca>
References: <Pine.LNX.4.10.10204111453020.15162-100000@luxik.cdi.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.10.10204111453020.15162-100000@luxik.cdi.cz>
List-Id: netdev.vger.kernel.org



On Thu, 11 Apr 2002, Martin Devera wrote:

> > Typically put() is the backup for delete. Should delete fail
> > to destroy because of reference counts being non-zero, put will catch it.
>
> So that if I understand it correctly: delete can only assure
> that class is "invisible" from now to subsequent gets/walks
> and other uses and leave actual destroy to the last put.
> Do you think that it is reasonable ?
>

sort of. If you look at the ATM scheduler, you should see the refcount
maybe incremented twice. In this case, delete will fail to destroy
the class but put() will catch it.
If you only increment/decrement then delete should always
catch it. In which case you dont need to destroy in put().
Your mileage may vary.

cheers,
jamal
