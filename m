From: "David S. Miller" <davem@davemloft.net>
Subject: Re: LLTX and netif_stop_queue
Date: Wed, 22 Dec 2004 20:29:19 -0800
Message-ID: <20041222202919.057b8331.davem@davemloft.net>
References: <52llbwoaej.fsf@topspin.com>
	<20041217214432.07b7b21e.davem@davemloft.net>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f04122210491d64d4b6@mail.gmail.com>
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

On Wed, 22 Dec 2004 19:49:48 +0100
Eric Lemoine <eric.lemoine@gmail.com> wrote:

> Instead, I would suggest to have LLTX drivers check whether queue is
> stopped after they grab their private tx lock and before they check tx
> ring fullness. That way we close the race window but keep the driver
> bug check around.
> 
> See attached sungem patch.

That sounds about right.  Nice idea.  It solves the race, and retains
the error state check.

I'll apply Eric's patch, and do something similar in the other LLTX
drivers (except loopback which has not "queue" per se so doesn't need
this stuff).
