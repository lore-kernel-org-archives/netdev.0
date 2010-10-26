From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC][net-next-2.6 PATCH 4/4] net: remove check for headroom
 in vlan_dev_create
Date: Tue, 26 Oct 2010 15:05:44 -0700
Message-ID: <4CC750B8.7060607@intel.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>	<20101021221020.22906.96059.stgit@jf-dev1-dcblab> <AANLkTinREMV1bRhoJuiRV805-e1NKdZD6ejyhYczpw_E@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30404 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760539Ab0JZWFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 18:05:45 -0400
In-Reply-To: <AANLkTinREMV1bRhoJuiRV805-e1NKdZD6ejyhYczpw_E@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2010 3:45 PM, Jesse Gross wrote:
> On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
> <john.r.fastabend@intel.com> wrote:
>> It is possible for the headroom to be smaller then the
>> hard_header_len for a short period of time after toggling
>> the vlan offload setting.
>>
>> This is not a hard error and skb_cow_head is called in
>> __vlan_put_tag() to resolve this.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> 
> How is it possible that the hard_header_len changes on the vlan
> device?  It looks like the header length never gets changed after it
> is initialized.  There's no set_flags method in the vlan device to
> toggle whether it is using offloading or not, it just rides on top of
> the underlying device.

Your right and I think this is why my previous patch was broken. If we
can toggle the underlying offloads we should set the header length as
well. With the updated patch I just sent this should be true now.

Thanks,
John.

> On the other hand, I agree that this check isn't actually necessary.

