From: Thomas Graf <tgraf@suug.ch>
Subject: Re: SFQ: Reordering?
Date: Sat, 7 May 2005 02:58:51 +0200
Message-ID: <20050507005851.GK28419@postel.suug.ch>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch> <427BFB72.7080407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <427BFB72.7080407@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <427BFB72.7080407@trash.net> 2005-05-07 01:19
> Thomas Graf wrote:
> > We can maintain a second hash table and switch a pointer over to the
> > new table but keep on dequeueing from the old one until it is empty.
> > Anyways, any such behaviour should be made optional via a rtnetlink
> > flag.
> 
> This also introduces unfairness. Packets of a flow could be only in
> the new table while we're still working on the active table.
> A proper solution to avoid reordering shouldn't be optional IMO,
> perturbation is already optional.

Yes, that's true but we can't reach perfect fairness anyway. What
is your primary goal? No reordering inside flows while staying
as fair as possible? I'm not sure whether it's worth to rehash
every single enqueued packet, especially not at a perturbation
interval of just a few seconds. Many scripts set it to a value
of 1..5 to have a higher theoreticaly fairness. That's why I think
this feature should be made optional
