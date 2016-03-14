From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next] ixgbe: Avoid unaligned access in ixgbe_atr()
 for LLC packets
Date: Mon, 14 Mar 2016 12:20:26 -0700
Message-ID: <CAKgT0Ud9b7MaOk-O4gs3LCMgO+dApCFJ=tOrStk1kuxEE5dShw@mail.gmail.com>
References: <20160314174624.GG5084@oracle.com>
	<CAKgT0Ucnf7Yyzjp_vccimVmjx-ZbYnOfKoTt6rEEZOsOEhVboQ@mail.gmail.com>
	<20160314175909.GH5084@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:32955 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbcCNTU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:20:27 -0400
Received: by mail-io0-f182.google.com with SMTP id n190so235206984iof.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 12:20:27 -0700 (PDT)
In-Reply-To: <20160314175909.GH5084@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 10:59 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (03/14/16 10:55), Alexander Duyck wrote:
>>
>> One other thing I forgot to mention is that we don't support ARP so
>> that check could be dropped.  The ATR code only supports IPv4 or IPv6
>> with TCP.
>
> I did notice that, but I left it in place because (a) it comes down
> the stack with the NET_IP_ALIGNment and (b) ARP is only sent over
> Ethernet II (there is no LLC SAP for ARP, which is a big reason
> why ipv4 is not sent over llc, despite rfc 1042).
>
> I figured it would not hurt to pass it down, in case we decide
> to do something clever with it in the future.

I figure it is better to just drop it since we don't need to be trying
to parse ARP packets anyway.

- Alex
