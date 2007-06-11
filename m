From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 18:00:16 +0300
Message-ID: <1ba2fa240706110800m643da3fam849805189c0540c9@mail.gmail.com>
References: <D0122E209EBF8D4CAB38EC6A8AF244E502AB28BA@hasmsx412.ger.corp.intel.com>
	 <1181573285.4077.22.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Cohen, Guy" <guy.cohen@intel.com>,
	"Patrick McHardy" <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:24862 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbXFKPAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 11:00:17 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1478007wxc
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 08:00:16 -0700 (PDT)
In-Reply-To: <1181573285.4077.22.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/11/07, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2007-11-06 at 17:30 +0300, Cohen, Guy wrote:
>
> >
> > For WiFi devices the HW often implements the scheduling, especially when
> > QoS (WMM/11e/11n) is implemented. There are few traffic queues defined
> > by the specs and the selection of the next queue to transmit a packet
> > from, is determined in real time, just when there is a tx opportunity.
> > This cannot be predicted in advance since it depends on the medium usage
> > of other stations.
>
> WMM is a strict prio mechanism.
> The parametrization very much favors the high prio packets when the
> tx opportunity to send shows up.
>

This is not true, there is no simple priority order from 1 to 4 ,
rather set of parameters that dermises access to medium.  You have to
emulate medium behavior to schedule packets in correct order. That's
why this pushed to HW, otherwise nobody would invest money in this
part of silicon :)

> > Hence, to make it possible for wireless devices to use the qdisc
> > mechanism properly, the HW queues should _ALL_ be non-empty at all
> > times, whenever data is available in the upper layers.
>
> agreed.
>
> > Or in other
> > words, the upper layers should not block a specific queue because of the
> > usage of any other queue.
>
> This is where we are going to disagree.
> There is no way the stack will send the driver packets which are low
> prio if there are some which are high prio. There is therefore, on
> contention between low and high prio, no way for low prio packets to
> obstruct the high prio packets; however, it is feasible that high prio
> packets will obstruct low prio packets (which is fine).
>
> cheers,
> jamal
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
