From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dev: use name hash for dev_seq_ops.
Date: Fri, 7 Oct 2011 09:24:45 -0700
Message-ID: <20111007092445.4f097ed9@nehalam.linuxnetplumber.net>
References: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	mirq-linux@rere.qmqm.pl, therbert@google.com, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dbaluta@ixiacom.com, Mihai Maruseac <mmaruseac@ixiacom.com>
To: Mihai Maruseac <mihai.maruseac@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318000849-2531-1-git-send-email-mmaruseac@ixiacom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  7 Oct 2011 18:20:49 +0300
Mihai Maruseac <mihai.maruseac@gmail.com> wrote:

> Instead of using the dev->next chain and trying to resync at each call to
> dev_seq_start, use this hash and store bucket number and bucket offset in
> seq->private field.
> 
> Tests revealed the following results for ifconfig > /dev/null
> 	* 1000 interfaces:
> 		* 0.114s without patch
> 		* 0.020s with patch
> 	* 3000 interfaces:
> 		* 0.489s without patch
> 		* 0.048s with patch
> 	* 5000 interfaces:
> 		* 1.363s without patch
> 		* 0.131s with patch
> 
> As one can notice the improvement is of 1 order of magnitude.

Good idea,
This will change the ordering of entries in /proc which may upset
some program, not a critical flaw but worth noting.

Rather than recording the bucket and offset of last entry, another
alternative would be to just record the ifindex.

Also ifconfig is considered deprecated and replaced by ip commands
for general use.
