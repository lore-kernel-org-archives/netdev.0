From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next] net: poll/select low latency socket support
Date: Tue, 18 Jun 2013 16:25:21 +0300
Message-ID: <51C05FC1.4000201@linux.intel.com>
References: <20130618085759.10941.15811.stgit@ladj378.jer.intel.com>  <20130618085810.10941.55039.stgit@ladj378.jer.intel.com> <1371551139.3252.249.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Avner Ben Hanoch <avnerb@mellanox.com>,
	Or Kehati <ork@mellanox.com>, sockperf-dev@googlegroups.com,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371551139.3252.249.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/06/2013 13:25, Eric Dumazet wrote:
> On Tue, 2013-06-18 at 11:58 +0300, Eliezer Tamir wrote:

>> @@ -731,7 +755,11 @@ static inline unsigned int do_pollfd(struct pollfd *pollfd, poll_table *pwait)
>>   			mask = DEFAULT_POLLMASK;
>>   			if (f.file->f_op && f.file->f_op->poll) {
>>   				pwait->_key = pollfd->events|POLLERR|POLLHUP;
>> +				if (try_ll)
>> +					pwait->_key |= POLL_LL;
>
> Well, why enforce POLL_LL ?
>
> Sure we do this for select() as the API doesn't allow us to add the LL
> flag, but poll() can do that.
>
> An application might set POLL_LL flag only on selected fds.

One other thing,
sock_poll() will only ll_poll if the flag was set _and_ the socket has a
none-zero value in sk->sk_ll_usec so you still only poll on sockets
that were enabled for LLS, not on every socket.

-Eliezer
