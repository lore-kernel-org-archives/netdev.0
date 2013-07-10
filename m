From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Wed, 10 Jul 2013 08:21:21 +0300
Message-ID: <51DCEF51.3080503@linux.intel.com>
References: <20130709162514.062f1361@lwn.net> <20130709.160611.636749585237773459.davem@davemloft.net> <51DCD50C.6070606@linux.intel.com> <20130709.214156.1738814737075691376.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, dwmw2@infradead.org,
	eliezer@tamir.org.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130709.214156.1738814737075691376.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 07:41, David Miller wrote:
> From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Date: Wed, 10 Jul 2013 06:29:16 +0300
> 
>> If the following names changes are acceptable I will try to send out
>> a patch today.

>> 2. ndo_ll_poll -> ndo_busy_poll
>>
>> - not technically accurate since the ndo callback does not itself busy
>> poll, it's just used to implement it.
> 
> I think this name change is accurate, it expresses the two elements of
> what it does.  It's busy waiting, in that it's doing a synchronous
> scan of the device's RX queue, and it's polling just like NAPI polling
> does.

OK

> Well... what would be great would be to come up with some single
> interface that drivers can implement rather than having to have
> both napi->poll and netdevice_ops->ndo_ll_poll().  But that's a task
> for a later date.
> 
> Therefore, ndo_busy_poll is probably best for now.

I will think about this, maybe we could even unify ndo_poll_controller.
It seems like said unified method would have to have an extra parameter
that would indicate from which context it was called:
1. from napi poll (bh)
2. from poll controller (with interrupts disabled)
3. from busy poll (user context)
-of course not for today.

> Nope, looks complete.  And also do the manpage update.

Where do I find the repository for the manpages?
