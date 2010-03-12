From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Fri, 12 Mar 2010 15:05:35 -0800
Message-ID: <65634d661003121505u6ad3d6adr50dc0ef8da7c726d@mail.gmail.com>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
	 <20100312142302.30def236@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:5791 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932279Ab0CLXFi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 18:05:38 -0500
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id o2CN5ab1020107
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:05:36 -0800
Received: from fg-out-1718.google.com (fgg19.prod.google.com [10.86.7.19])
	by wpaz17.hot.corp.google.com with ESMTP id o2CN5ZdG009683
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:05:35 -0800
Received: by fg-out-1718.google.com with SMTP id 19so547961fgg.5
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 15:05:35 -0800 (PST)
In-Reply-To: <20100312142302.30def236@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 12, 2010 at 2:23 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Fri, 12 Mar 2010 12:13:12 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
>
>> if (unlikely(index >=3D dev->num_rx_queues)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (net_ratelimit()) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN(1, "R=
eceived packet on %s for queue %u, "
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "b=
ut number of RX queues is %u\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
dev->name, index, dev->num_rx_queues);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
>
>
> Use dev_WARN? or invent netdev_WARN?
>

netdev_warn looks good.  I'll use that here and also in
dev_cap_txqueue where WARN is similarly used to be consistent.

Tom
