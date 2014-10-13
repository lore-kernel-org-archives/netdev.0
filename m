From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable v3.2 v3.4] ipv4: disable bh while doing route gc
Date: Mon, 13 Oct 2014 13:51:27 -0400 (EDT)
Message-ID: <20141013.135127.1915115817707962111.davem@davemloft.net>
References: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org
To: mleitner@redhat.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Mon, 13 Oct 2014 14:03:30 -0300

> Further tests revealed that after moving the garbage collector to a work
> queue and protecting it with a spinlock may leave the system prone to
> soft lockups if bottom half gets very busy.
> 
> It was reproced with a set of firewall rules that REJECTed packets. If
> the NIC bottom half handler ends up running on the same CPU that is
> running the garbage collector on a very large cache, the garbage
> collector will not be able to do its job due to the amount of work
> needed for handling the REJECTs and also won't reschedule.
> 
> The fix is to disable bottom half during the garbage collecting, as it
> already was in the first place (most calls to it came from softirqs).
> 
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Acked-by: David S. Miller <davem@davemloft.net>
> Cc: stable@vger.kernel.org

-stable folks, please integrate this directly, thanks!
