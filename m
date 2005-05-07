From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ: Reordering?
Date: Sat, 07 May 2005 03:28:35 +0200
Message-ID: <427C19C3.5030304@trash.net>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch> <427BFB72.7080407@trash.net> <20050507005851.GK28419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050507005851.GK28419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <427BFB72.7080407@trash.net> 2005-05-07 01:19
> 
>>This also introduces unfairness. Packets of a flow could be only in
>>the new table while we're still working on the active table.
>>A proper solution to avoid reordering shouldn't be optional IMO,
>>perturbation is already optional.
> 
> 
> Yes, that's true but we can't reach perfect fairness anyway. What
> is your primary goal? No reordering inside flows while staying
> as fair as possible? I'm not sure whether it's worth to rehash
> every single enqueued packet, especially not at a perturbation
> interval of just a few seconds. Many scripts set it to a value
> of 1..5 to have a higher theoreticaly fairness. That's why I think
> this feature should be made optional

You stated my goal precisely :) I know many people set the interval
to too low values, but because of the tight limits, it shouldn't be
very expensive anyways. Table switching OTOH would introduce frequently
occuring unfairness, and the time to work through a full table is
a lot longer, especially in the environments where SFQ is used.
It would be interesting to see this in real-life, when a single flow
is hashed to multiple buckets (it can be even more than two) and
each bucket has some packets queued, the result should look pretty
chaotic.

Regards
Patrick
