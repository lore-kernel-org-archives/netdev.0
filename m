From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Mon, 3 Jan 2005 16:48:00 +0100
Message-ID: <5cac192f05010307484f23bca5@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<1103484675.1050.158.camel@jzny.localdomain>
	<5cac192f04122210491d64d4b6@mail.gmail.com>
	<20041222202919.057b8331.davem@davemloft.net>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andi Kleen <ak@suse.de>,
	openib-general@openib.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <1104764660.1048.578.camel@jzny.localdomain>
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

On 03 Jan 2005 10:04:21 -0500, jamal <hadi@cyberus.ca> wrote:
> this piece:
> -----
> +
> +                       /* And release queue */
> +                       spin_unlock(&dev->queue_lock);
>                 }
> ---------
> 
> Isnt there a possibility (higher as you increase number of processors)
> that you will spin for a long time in _the driver_ waiting for the queue
> lock?

I don't see how LLTX is different from non-LLTX wrt the time spent
spinning on queue_lock. What am i missing?

> 
> Maybe we need a flag "the queue lock" is already been grabbed passed
> to the driver. LLTX is a good  alias but insufficient (if you run your
> driver in an old kernels which support LLTX but not the idea of locking
> the queue for you).
> 
> Andi or anyone else - has anyone really done perfomance analysis of LLTX
> (with anything other than loopback) and shown it has any value? Maybe
> time to just shoot the damn thing.

I do not like LLTX too much either as I can't see a cleaner way to get
rid of that packet reordering race condition.

-- 
Eric
