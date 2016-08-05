From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC V2 PATCH 17/25] net/netpolicy: introduce netpolicy_pick_queue
Date: Fri, 5 Aug 2016 07:38:01 -0700
Message-ID: <CALx6S35RnPwqvRepCZ8Jgu0inkCvCtfM41An9YVEP8cy=9dSjw@mail.gmail.com>
References: <1470339389-8542-1-git-send-email-kan.liang@intel.com>
 <1470339389-8542-18-git-send-email-kan.liang@intel.com> <CALx6S37NbXVh-vS=Vxrm_8qhhOsOkPy-+hLTUGk=E57yKBkCyQ@mail.gmail.com>
 <37D7C6CF3E00A74B8858931C1DB2F07712C237BE@SHSMSX103.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	"peterz@infradead.org" <peterz@infradead.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	"viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"gorcunov@openvz.org" <gorcunov@openvz.org>,
	John Stultz <john.stultz@linaro.org>,
	Alex Duyck <aduyck@mirantis.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Decotigny <decot@googlers.com>,
	Florian Westphal <fw@strlen.de>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"rdunlap@infradead.org" <rdunlap@infradead.org>,
	C
To: "Liang, Kan" <kan.liang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <37D7C6CF3E00A74B8858931C1DB2F07712C237BE@SHSMSX103.ccr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 5, 2016 at 6:55 AM, Liang, Kan <kan.liang@intel.com> wrote:
>
>
>>
>> On Thu, Aug 4, 2016 at 12:36 PM,  <kan.liang@intel.com> wrote:
>> > From: Kan Liang <kan.liang@intel.com>
>> >
>> > To achieve better network performance, the key step is to distribute
>> > the packets to dedicated queues according to policy and system run
>> > time status.
>> >
>> > This patch provides an interface which can return the proper dedicated
>> > queue for socket/task. Then the packets of the socket/task will be
>> > redirect to the dedicated queue for better network performance.
>> >
>> > For selecting the proper queue, currently it uses round-robin
>> > algorithm to find the available object from the given policy object
>> > list. The algorithm is good enough for now. But it could be improved
>> > by some adaptive algorithm later.
>> >
>> Seriously? You want to all of this code so we revert to TX queue selection by
>> round robin?
>>
>
> I agree that the round robin is not an optimal algorithm.
> For this series, we intends to provide a generic infrastructure for review.
> For the algorithm parts, it's already in our TODO list. We will replace it later.
>
Kan,

The justification for this patch is that to achieve to network
performance to steer TX distribute the packets to according to policy
and system runtime status. But the patch doesn't remotely implement
that, there's no data provided that these do anything useful or ever
will do anything useful, and it seems like this is completely ignoring
existing mechanisms like XPS that have proven to improve performance.

Tom
