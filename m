From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 24 Nov 2015 19:16:29 +0100
Message-ID: <1448388989.598069.449003345.12D1FBF9@webmail.messagingengine.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
 <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
 <CAEh+42jWN961Gg59xbdXiFj9u7=3vuFdyXkcr6iPJ92ZizPpGw@mail.gmail.com>
 <C40BE8378EF49C44B9184714DBC8EF29939A13AA@ORSMSX115.amr.corp.intel.com>
 <CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
 <20151123171103.00007699@unknown>
 <CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
 <1448387015.235472.448970977.10694A74@webmail.messagingengine.com>
 <CALx6S37AVnVxbcW=N451qH1VKiNJ1HZYEj8eqob-4hXWcHbD3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Singhai, Anjali" <anjali.singhai@intel.com>,
	Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:60184 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754239AbbKXSQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:16:29 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 5722D20809
	for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 13:16:29 -0500 (EST)
In-Reply-To: <CALx6S37AVnVxbcW=N451qH1VKiNJ1HZYEj8eqob-4hXWcHbD3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, Nov 24, 2015, at 18:52, Tom Herbert wrote:
> On Tue, Nov 24, 2015 at 9:43 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Tue, Nov 24, 2015, at 18:32, Tom Herbert wrote:
> >> As you said this in only feedback and nobody is forcing anyone to do
> >> anything. But encouraging HW vendors to provide generic mechanisms so
> >> that your users can use whatever protocol they want is the exact
> >> _opposite_ of punishing users, this is very much a pro-user direction.
> >
> > Some users will suffer worse performance in case we don't correctly set
> > ip_summed for a specific protocol before we do the copy operations from
> > user space into skbs but if they are always done in the driver.
> >
> Please be specific. Who are the users, what is exact performance
> regression, what are specific protocols in question?

Depending on ip_summed after a connect on a socket and having the
correct dst_entry we either copy data from user space and calculate the
checksum concurrently or let the hardware do that
(csum_partial_from_user).

In case someone owns a IPv4 capable but not IPv6 capable checksum
offloading NIC they will end up in the slow path in the driver either
for IPv4 xor IPv6 because out of one we could not set the correct
ip_summed mode before copy to the kernel.

Data during transmit seems to be cold already, so a proper checksum
while we touch the data anyway would be favorable.

Bye,
Hannes
