From: "Yigal Reiss (yreiss)" <yreiss@cisco.com>
Subject: RE: [PATCH net-next] change nfqueue failopen to apply also to receive
 message buffer in addition to queue size
Date: Wed, 23 Mar 2016 12:04:28 +0000
Message-ID: <727dce6253224081b6bc4bd40c6e1958@XCH-RTP-014.cisco.com>
References: <2ba8dceec36a41149598e43f09af048e@XCH-RTP-014.cisco.com>
 <20160321122236.GB29493@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"pablo@netfilter.org" <pablo@netfilter.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160321122236.GB29493@breakpoint.cc>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Much of the issues raised become redundant due to a much simpler solution proposed by Pablo. Still two issues left, proc and potential existing bug in sk filter case. 

On March 21, 2016 2:23 PM, Florian Westphal wrote:
> It looks like a bug -- AFAICS if a sk filter is active on the nfnetlink sk we will believe sk got queued and will put the (free'd) skb ptr on the reinject list.
This issue may still need to be looked at separately.

> Userspace already should get -ENOBUFS errors on netlink overrun.
-ENOBUFS doesn't provide statistics. It does not detect queue limitation. Also diagnostic needs are many times different than implementation needs. Also many times user uses NETLINK_NO_ENOBUFS in order to avoid penalty for buffer overruns (as for example done in a patch to daq_nfq submitted by you here (http://seclists.org/snort/2011/q2/311) :-) ).

>>  -	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %2d\n",
>>  +	seq_printf(s, "%5u %6u %5u %1u %5u %5u %5u %8u %5u %5u %2d\n",
> Problematic since it changes layout of a file we unfortunately have to view as uapi.
> I would prefer if we could leave the proc file alone and not add any new stats counters for this, unless there is a good argument for doing so.
So my arguments are that there in order to fine tune a system it is required to know about the existence and number of packets that went under the radar. As I wrote ENOBUF does not answer all these needs.
I understand it is problematic to change uapi. Tried to minimize incompatibility by keeping the order of arguments. I'll probably use a patch to proc any way. Please let me know if you think there is a point in proposing this patch or is it a "no-no" from kernel's perspective.


