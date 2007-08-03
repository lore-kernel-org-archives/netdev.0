From: Daniel Phillips <phillips@phunq.net>
Subject: Re: Distributed storage.
Date: Fri, 3 Aug 2007 12:41:58 -0700
Message-ID: <200708031241.58635.phillips@phunq.net>
References: <20070731171347.GA14267@2ka.mipt.ru> <1186144072.11797.55.camel@lappy> <20070803134943.GA21221@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070803134943.GA21221@2ka.mipt.ru>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 03 August 2007 06:49, Evgeniy Polyakov wrote:
> ...rx has global reserve (always allocated on
> startup or sometime way before reclaim/oom)where data is originally
> received (including skb, shared info and whatever is needed, page is
> just an exmaple), then it is copied into per-socket reserve and
> reused for the next packet. Having per-socket reserve allows to have
> progress in any situation not only in cases where single action must
> be received/processed, and allows to be completely fair for all
> users, but not only special sockets, thus admin for example would be
> allowed to login, ipsec would work and so on...

And when the global reserve is entirely used up your system goes back to 
dropping vm writeout acknowledgements, not so good.  I like your 
approach, and specifically the copying idea cuts out considerable 
complexity.  But I believe the per-socket flag to mark a socket as part 
of the vm writeout path is not optional, and in this case it will be a 
better world if it is a slightly unfair world in favor of vm writeout 
traffic.

Ssh will still work fine even with vm getting priority access to the 
pool.  During memory crunches, non-vm ssh traffic may get bumped till 
after the crunch, but vm writeout is never supposed to hog the whole 
machine.  If vm writeout hogs your machine long enough to delay an ssh 
login then that is a vm bug and should be fixed at that level.

Regards,

Daniel
