From: jamal <hadi@cyberus.ca>
Subject: Re: QoS _put, _get and _delete class ops semantic
Date: Thu, 11 Apr 2002 08:35:22 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204101918200.24339-100000@shell.cyberus.ca>
References: <Pine.LNX.4.10.10204091332410.15162-100000@luxik.cdi.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Martin Devera <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.10.10204091332410.15162-100000@luxik.cdi.cz>
List-Id: netdev.vger.kernel.org


Hi Martin,

On Tue, 9 Apr 2002, Martin Devera wrote:

> Hi Jamal,
>
> put and get seem to be simply reference counting on
> class object.

nod

> I'd expect thet class creation will call
> get once to assure that it is locked in active state and
> "tc class del" would call last put to release this last
> reference (and class will destroy itself).

actually sequence would be get();delete();put() whenever
"tc class del" is invoked (theres other activity that may happen here as
well instead of delete(), example attaching filters to class etc).

I think what you do with the delete+put combo is specific
to your needs though. So for example you could return 0
in get() and your put() code will never be invoked.

> Unfortunately there is delete class op which seems to do
> almost the same as put.
> Do you know rationale behind it ? Why we have both put
> and delete and what tc framework expect from qdisc ?

Alexey can give a better answer.
Typically put() is the backup for delete. Should delete fail
to destroy because of reference counts being non-zero, put will catch it.
CBQ is an easier scheduler to see this. For a fun one look at the ATM
scheduler.

cheers,
jamal
