From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] subset of RFC2553
Date: Wed, 12 Feb 2003 21:43:05 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030212.214305.67672796.davem@redhat.com>
References: <1045091741.8858.320.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: bwa@us.ibm.com
In-Reply-To: <1045091741.8858.320.camel@w-bwa1.beaverton.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Bruce Allan <bwa@us.ibm.com>
   Date: 12 Feb 2003 15:15:39 -0800

I don't like how sockaddr_storage works, so you'll have to clean
it up before we move it to a generic spot.

   +struct sockaddr_storage {
   +	sa_family_t  ss_family;			/* address family */
   +	/* Following fields are implementation specific */
   +	char      __ss_pad1[_SS_PAD1SIZE];
   +				/* 6 byte pad, this is to make implementation */
   +				/* specific pad up to alignment field that */
   +				/* follows explicit in the data structure */
   +	int64_t   __ss_align; 	/* field to force desired structure */
   +				/* storage alignment */
   +	char      __ss_pad2[_SS_PAD2SIZE];
   +				/* 112 byte pad to achieve desired size, */
   +				/* _SS_MAXSIZE value minus size of ss_family */
   +				/* __ss_pad1, __ss_align fields is 112 */
   +};

All of this pad stuff is really unnecessary, just specify ss_family
and then "stuff" where "stuff" can be something like "char __data[0];"
Then you can add "attribute((aligned(64)))" or whatever to the
declaration as well.

And if you're going to put some 64-bit type in here, use "__u64"
which actually makes you consistent with the rest of the kernel.

You could also do something like:

	__u64	data[_SS_MAXSIZE / sizeof(__u64)];

Anything but this pad stuff...
