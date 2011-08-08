From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 8 Aug 2011 10:56:21 -0700
Message-ID: <CA+mtBx8s9sOLcPXz+YM7BqqHXi65RA0k93ORfkHY-BQUVvQ+kw@mail.gmail.com>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<20110808084016.063a0699@nehalam.ftrdhcpuser.net>
	<CA+mtBx_vgsH+uHLi6p80E8CEhU7SHXY=Fw1Z-W2OFWy44LP-ig@mail.gmail.com>
	<20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:53434 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819Ab1HHR4Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 13:56:25 -0400
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p78HuNjB026645
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 10:56:23 -0700
Received: from iym1 (iym1.prod.google.com [10.241.52.1])
	by kpbe12.cbf.corp.google.com with ESMTP id p78HuLPG026726
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2011 10:56:22 -0700
Received: by iym1 with SMTP id 1so9522531iym.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 10:56:21 -0700 (PDT)
In-Reply-To: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 8, 2011 at 10:55 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 8 Aug 2011 10:51:06 -0700
> Tom Herbert <therbert@google.com> wrote:
>
>> On Mon, Aug 8, 2011 at 8:40 AM, Stephen Hemminger <shemminger@vyatta=
=2Ecom> wrote:
>> > On Sun, 7 Aug 2011 21:43:13 -0700 (PDT)
>> > Tom Herbert <therbert@google.com> wrote:
>> >
>> >> =A0 =A0 netdev_tx_completed_queue: Called at end of transmit comp=
letion
>> >> =A0 =A0 =A0 to inform stack of number of bytes and packets proces=
sed.
>> >> =A0 =A0 netdev_tx_sent_queue: Called to inform stack when packets=
 are
>> >> =A0 =A0 =A0 queued.
>> >
>> > Couldn't these be done for the device in the existing qdisc infra
>> > structure (or dev_start_xmit). Alternatively, rename ndo_start_xmi=
t
>> > to something else and make all the callers use the wrapper.
>> >
>> > Changing all the drivers for something that the driver has no real
>> > need to care about seems like incorrect object design.
>> >
>> The netdev_tx_completed_queue is needed to inform the stack of numbe=
r
>> of packets and bytes completed in an execution of transmit completio=
n
>> (epic). =A0I don't see a way to get that information outside of the
>> driver.
>>
>> Tom
>
> Since transmit completion means calling dev_kfree_skb() why not accou=
nt
> there? You could add some info to netdev if necessary to get compile
> the statistics.
>
> I just hate driver api complexity growth.
>
>
