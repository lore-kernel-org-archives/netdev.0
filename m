From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Re: [PATCH 6/6] IB: userspace support for RDMA
	connection manager
Date: Mon, 06 Mar 2006 14:32:28 -0800
Message-ID: <aday7zn432b.fsf@cisco.com>
References: <adaoe0j5kd6.fsf@cisco.com> <440CACB5.2010609@ichips.intel.com>
	<adabqwj5j7b.fsf@cisco.com>
	<20060306.142814.109285730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060306.142814.109285730.davem@davemloft.net> (David S.
	Miller's message of "Mon, 06 Mar 2006 14:28:14 -0800 (PST)")
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

    David> Please make sure you check "x86_64 vs. x86", and then
    David> something like "powerpc64 vs. powerpc32" or "sparc64
    David> vs. sparc32", as those are the two different classes of ABI
    David> layouts.

Yes, I tried ppc64 vs ppc and it still comes out the same.
Unfortunately I don't have any sparc handy to try.

The fundamental question seems to be whether things like

	struct foo {
		struct sockaddr_in6 src;
		struct sockaddr_in6 dst;
	};

and

	struct bar {
		struct sockaddr_in6 a;
		__u32 b;
	};

end up being packed, even though struct sockaddr_in6 is 28 bytes in
size.  And as far as I can tell, they always do, I guess because the
individual fields of struct sockaddr_in6 are all <= 32 bits.

 - R.
