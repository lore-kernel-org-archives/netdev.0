From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Thu, 23 Dec 2004 10:10:34 +0100
Message-ID: <5cac192f0412230110628749e3@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041222202919.057b8331.davem@davemloft.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Dec 2004 20:29:19 -0800, David S. Miller <davem@davemloft.net> wrote:
> On Wed, 22 Dec 2004 19:49:48 +0100
> Eric Lemoine <eric.lemoine@gmail.com> wrote:
> 
> > Instead, I would suggest to have LLTX drivers check whether queue is
> > stopped after they grab their private tx lock and before they check tx
> > ring fullness. That way we close the race window but keep the driver
> > bug check around.
> >
> > See attached sungem patch.
> 
> That sounds about right.  Nice idea.  It solves the race, and retains
> the error state check.
> 
> I'll apply Eric's patch, and do something similar in the other LLTX
> drivers (except loopback which has not "queue" per se so doesn't need
> this stuff).

Dave,

I still have one concern with the LLTX code (and it may be that the
correct patch is Jamal's) :

Without LLTX we do : lock(queue_lock), lock(xmit_lock),
release(queue_lock), release(xmit_lock). With LLTX (without Jamal's
patch) we do : lock(queue_lock), release(queue_lock), lock(tx_lock),
release(tx_lock). LLTX doesn't look correct because it creates a race
condition window between the the two lock-protected sections. So you
may want to reconsider Jamal's patch or pull out LLTX...

Thanks, 

-- 
Eric
