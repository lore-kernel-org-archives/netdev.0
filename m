From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] macvlan: don't touch promisc without passthrough
Date: Wed, 12 Jun 2013 23:02:01 -0700
Message-ID: <51B96059.4070104@gmail.com>
References: <1371035949-29471-1-git-send-email-mst@redhat.com> <51B87E0D.8040009@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roopa Prabhu <roprabhu@cisco.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51B87E0D.8040009@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/12/2013 06:56 AM, Sergei Shtylyov wrote:
> Hello.
>
> On 12-06-2013 15:34, Michael S. Tsirkin wrote:
>
>> commit df8ef8f3aaa6692970a436204c4429210addb23a in linux 3.5 added a way
>
>     Please also specify that commit's summary line in parens.
>
>> to control NOPROMISC macvlan flag through netlink.
>
>> However, with a non passthrough device we don't set promisc on open or
>> clear it on stop, even if NOPROMISC is off.  As a result:
>
>> If userspace clears NOPROMISC on open, then does not clear it on a
>> netlink command, promisc counter is not decremented on stop and there
>> will be no way to clear it once macvlan is detached.
>
>> If userspace does not clear NOPROMISC on open, then sets NOPROMISC on a
>> netlink command, promisc counter will be decremented from 0 and overflow
>> to fffffffff with no way to clear promisc afterwards.
>
>> To fix, simply ignore NOPROMISC flag in a netlink command for
>> non-passthrough devices, same as we do at open/stop.
>
>> While at it - since we touch this code anyway - check
>> dev_set_promiscuity return code and pass it to users (though an error
>> here is unlikely).
>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> CC: Roopa Prabhu <roprabhu@cisco.com>
>> Cc: John Fastabend <john.r.fastabend@intel.com>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>
>> Please review, and consider for 3.10 and -stable.
>

Other than those few nits looks good to me thanks!

Reviewed-by: John Fastabend <john.r.fastabend@intel.com>

-- 
John Fastabend         Intel Corporation
