From: Jesse Gross <jesse@nicira.com>
Subject: Re: [RFC][net-next-2.6 PATCH 4/4] net: remove check for headroom in vlan_dev_create
Date: Mon, 25 Oct 2010 15:45:09 -0700
Message-ID: <AANLkTinREMV1bRhoJuiRV805-e1NKdZD6ejyhYczpw_E@mail.gmail.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
	<20101021221020.22906.96059.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:62791 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755834Ab0JYWpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 18:45:10 -0400
Received: by gwj21 with SMTP id 21so2928880gwj.19
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 15:45:09 -0700 (PDT)
In-Reply-To: <20101021221020.22906.96059.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 3:10 PM, John Fastabend
<john.r.fastabend@intel.com> wrote:
> It is possible for the headroom to be smaller then the
> hard_header_len for a short period of time after toggling
> the vlan offload setting.
>
> This is not a hard error and skb_cow_head is called in
> __vlan_put_tag() to resolve this.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

How is it possible that the hard_header_len changes on the vlan
device?  It looks like the header length never gets changed after it
is initialized.  There's no set_flags method in the vlan device to
toggle whether it is using offloading or not, it just rides on top of
the underlying device.

On the other hand, I agree that this check isn't actually necessary.
