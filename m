From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other macvlan devices
Date: Wed, 18 Nov 2009 15:55:38 -0800
Message-ID: <m1bpiz8k1x.fsf@fess.ebiederm.org>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de>
	<200911181047.07974.arnd@arndb.de> <m1pr7fdhkx.fsf@fess.ebiederm.org>
	<200911182332.56309.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757353AbZKRXzs@vger.kernel.org>
In-Reply-To: <200911182332.56309.arnd@arndb.de> (Arnd Bergmann's message of "Wed\, 18 Nov 2009 23\:32\:56 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> On Wednesday 18 November 2009 14:37:50 Eric W. Biederman wrote:
>> Arnd Bergmann <arnd@arndb.de> writes:
>> > On Wednesday 18 November 2009, Eric Dumazet wrote:
>> >> 
>> >> Why do you drop dst here ?
>> >> 
>> >> It seems strange, since this driver specifically masks out IFF_XMIT_DST_RELEASE
>> >> in its macvlan_setup() :
>> >> 
>> >> dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
>
> It seems that we should never drop dst then. We either forward the frame to
> netif_rx or to dev_queue_xmit, and from how I read it now, we want to keep
> the dst in both cases.

When we loop back on our selves we certainly need to have dst clear because
we don't know how to cache routes through multiple network namespaces.  It
might be handy if we had those but that is a problem for another day.

>> Please copy and ideally share code with the veth driver for recycling a skb.
>> There are bunch of little things you have to do to get it right.  As I recally
>> I was missing a few details in my original patch.
>
> Are you thinking of something like the patch below? I haven't had the chance
> to test this, but one thing it does is to handle the internal forwarding
> differently from the receive path.

Yes.  That is a bit more sharing than I had anticipated, but it looks like
it works.

Eric
