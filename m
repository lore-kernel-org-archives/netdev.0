From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: tc drop stats different between bond and slave interfaces
Date: Thu, 28 May 2015 10:33:19 -0400 (EDT)
Message-ID: <2070535585.119404.1432823599221.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
References: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net> <CAHA+R7MnHDVayA3MqpyR7J09tGNdh=OMmJAZG-0+rRhsmCNTNA@mail.gmail.com>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:49584 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbbE1OdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 10:33:20 -0400
In-Reply-To: <CAHA+R7MnHDVayA3MqpyR7J09tGNdh=OMmJAZG-0+rRhsmCNTNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 26, 2015 at 1:10 PM Cong Wang <cwang@twopensource.com> wrote:
>
>
> On Mon, May 25, 2015 at 10:35 PM, jsullivan@opensourcedevel.com
> <jsullivan@opensourcedevel.com> wrote:
> >
> > I was also surprised to see that, although we are using a prio qdisc on the
> > bond, the physical interface is showing pfifo_fast.
> >
> [...]
> >
> > So why the difference and why the pfifo_fast qdiscs on the physical
> > interfaces?
>
> Qdisc is not aware of the network interface you attach it to, so it doesn't
> know
> whether it is bond or whatever stacked interface, the qdisc you add to bonding
> master has no idea about its slaves.
>
> For pfifo_fast, it is the default qdisc when you install mq on root, it is
> where
> mq actually holds the packets.
>
> Hope this helps.

Grr . . . . I think this web client formatted my last response with HTML by
default.  My apologies.

Yes, your reply does help, thank you although it then raises an interesting
question.  If I
neglect the slave interfaces as I have done, can I accidentally impact the
shaping I have done on the bond master? For example, I may prioritize real time
voice and video so their relatively evenly spaced packets are prioritized and
sent to the physical interface with no special ToS marking.  Someone's selfish
mail application sets ToS bits for high priority and decides to send a huge
attachment.  Those packets also flood into the physical interface behind the
video and voice packets but now the physical interface using pfifo_fast sends
the bulk email packets ahead of the voice and video.  Is this an accurate
scenario?
 
Thus, if one uses traffic shaping on a bonded interface, should one then do
something like use a prio qdisc with a single priority on the physical
interfaces? Thanks - John
