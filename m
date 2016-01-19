From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: fix potential infinite loop in SO_REUSEPORT
 logic
Date: Tue, 19 Jan 2016 13:53:22 -0500 (EST)
Message-ID: <20160119.135322.2284631396199693528.davem@davemloft.net>
References: <1453171769.1223.255.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAEfhGizQXqMCbSbi-CCp=Ct7-Mb+0ROtPMYVTAb_GusgQOY6VQ@mail.gmail.com>
	<1453221403.1223.266.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kraigatgoog@gmail.com, dvyukov@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453221403.1223.266.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jan 2016 08:36:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Using a combination of connected and un-connected sockets, Dmitry
> was able to trigger soft lockups with his fuzzer.
> 
> The problem is that sockets in the SO_REUSEPORT array might have
> different scores.
> 
> Right after sk2=socket(), setsockopt(sk2,...,SO_REUSEPORT, on) and
> bind(sk2, ...), but _before_ the connect(sk2) is done, sk2 is added into
> the soreuseport array, with a score which is smaller than the score of
> first socket sk1 found in hash table (I am speaking of the regular UDP
> hash table), if sk1 had the connect() done, giving a +8 to its score.
> 
> hash bucket [X] -> sk1 -> sk2 -> NULL
> 
> sk1 score = 14  (because it did a connect())
> sk2 score = 6
> 
> SO_REUSEPORT fast selection is an optimization. If it turns out the
> score of the selected socket does not match score of first socket, just
> fallback to old SO_REUSEPORT logic instead of trying to be too smart.
> 
> Normal SO_REUSEPORT users do not mix different kind of sockets, as this
> mechanism is used for load balance traffic.
> 
> Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Craig Gallek <kraigatgoog@gmail.com>

Applied, thanks Eric.
