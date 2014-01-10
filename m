From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Fri, 10 Jan 2014 20:16:48 +0100
Message-ID: <52D04720.5070408@redhat.com>
References: <1389358907-19885-1-git-send-email-dborkman@redhat.com> <CAHA+R7NPyEmSpmojrM6pOsAVq3B6NjVWWCw0oQMPZFdCaDW9sA@mail.gmail.com> <52D044E0.1090206@redhat.com> <20140110111233.3364ec17@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42915 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbaAJTQ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 14:16:57 -0500
In-Reply-To: <20140110111233.3364ec17@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2014 08:12 PM, Stephen Hemminger wrote:
> On Fri, 10 Jan 2014 20:07:12 +0100
> Daniel Borkmann <dborkman@redhat.com> wrote:
>
>>>> +       BUG_ON(!rtnl_is_locked());
>>>
>>>
>>> This is not necessary at all, it is known that netdev notication
>>> holds rtnl lock.
>>
>> We're not in fast-path, and if someone would call that function outside
>> of the notifier chain, it might be good to check if the lock was taken,
>> but if there's a strong opinion to not have that, I'll just remove it
>
> First, the standard way to do this is ASSERT_RTNL()
>
> Second, it is unnecessary. The function is local, only called through
> notifier and notifiers always have RTNL held.

Ok, I'll just remove it, and resend if you're fine with this.
