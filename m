From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: enhancing nfnetlink stats [was Re: [PATCH net-next] change nfqueue
 failopen to apply also to receive message buffer in addition to queue size]
Date: Wed, 23 Mar 2016 13:28:55 +0100
Message-ID: <20160323122855.GA5355@salvia>
References: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
 <20160321122236.GB29493@breakpoint.cc>
 <727dce6253224081b6bc4bd40c6e1958@XCH-RTP-014.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <727dce6253224081b6bc4bd40c6e1958@XCH-RTP-014.cisco.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 23, 2016 at 12:04:28PM +0000, Yigal Reiss (yreiss) wrote:
> >>  -	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %2d\n", +
> >>  seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %5u %5u %2d\n",
> > Problematic since it changes layout of a file we unfortunately
> > have to view as uapi.  I would prefer if we could leave the proc
> > file alone and not add any new stats counters for this, unless
> > there is a good argument for doing so.
>
> So my arguments are that there in order to fine tune a system it is
> required to know about the existence and number of packets that went
> under the radar. As I wrote ENOBUF does not answer all these needs.
> I understand it is problematic to change uapi. Tried to minimize
> incompatibility by keeping the order of arguments. I'll probably use
> a patch to proc any way. Please let me know if you think there is a
> point in proposing this patch or is it a "no-no" from kernel's
> perspective.

I'd suggest you extend the existing nfnetlink_queue infrastructure so
we retrieve these statistics through netlink, ie. add the
NFQNL_MSG_STATS message. Then, extend nft so we can list them via:

# nft list queues
... [ stats here ] ...
