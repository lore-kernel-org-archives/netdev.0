From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: use reciprocal_divide instead of
 reimplementing it
Date: Tue, 03 Sep 2013 07:02:34 -0700
Message-ID: <1378216954.7360.25.camel@edumazet-glaptop>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
	 <1378204010-27050-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1378204010-27050-3-git-send-email-dborkman@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-09-03 at 12:26 +0200, Daniel Borkmann wrote:
> Replace these places with reciprocal_divide() inline function instead of
> reimplementing it each time, thus it will become easier to read. We do not
> need to explicitly include its header as it's pulled in from linux/net.h
> anyway.

Sure, (((u64) hash * qcount) >> 32) happens to be
reciprocal_divide(hash, qcount) but the result depends on hash being
well distributed in [0 .. ~0U] space.

So 'reciprocal' and 'divide' do not accurately describe this exact
operation.

I suggest making the thing more descriptive.

(And discussed on lkml btw)


