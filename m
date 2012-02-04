From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Fri, 3 Feb 2012 23:40:09 -0500
Message-ID: <CAK6E8=e-7aPTqKAidT7XJE1D8zheBj=GMApN8rSxQX8YP-Berw@mail.gmail.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net> <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Satoru Moriya <satoru.moriya@hds.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:49833 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751561Ab2BDEk3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Feb 2012 23:40:29 -0500
Received: by obcva7 with SMTP id va7so5047176obc.19
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2012 20:40:29 -0800 (PST)
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Satoru,

I totally understand that you need deeper instrumentation for *your*
business. At Google, we instrument a lot more in TCP as well. But we
have yet to upstream these changes because it's not universally useful
for default Linux kernel. I failed to see how different failures of a
TCP retransmission must be recorded and exported. Could you elaborate
your last point?

On Fri, Feb 3, 2012 at 4:47 PM, Satoru Moriya <satoru.moriya@hds.com> w=
rote:
>
> On 01/20/2012 01:50 PM, David Miller wrote:
> > You were given an alternative way to trace these kinds of events, a=
nd
> > you have yet to give us a solid reason why that cannot work for you=
=2E
>
> OK. I'll try to explain it.
>
> First of all, we'd like to use this tracepoint with our
> flight recorder.
>
> tcpdump:
> =A0tcpdump captures all the packets and so its overhead is not
> =A0acceptable. Also we can't keep the data on memory but must
> =A0write the data to file for each time. It introduce other
> =A0overhead which we can't accept.
>
> commit 63e03724b51, dropwatch, skb:kfree_skb:
> =A0With this tracepoint, we can detect packet drop.
> =A0But it may be too late because with tcp kernel retransmits
> =A0packets repeatedly if it can't get ack and after that it
> =A0may drops packets in a no-win situation.
> =A0Also sometimes customer finds delays which is caused by
> =A0temporal packet drop and retransmission. With this tracepoint
> =A0we can explain it based on the real data.
>
> netstat:
> =A0This is a good tool for the first step to analyze what
> =A0happened. But it shows only statistics and it's not enough
> =A0for us to analyze incidents and explain it to our customers.
> =A0We need each packet drop data(when it happen, whether it
> =A0succeeded or not etc.)
>
> systemtap:
> =A0Actually, we've already used systemtap in our flight recorder.
> =A0But we believe that tcp retransmission is one of the fundamental
> =A0function in tcp stack and so kernel itself should provide the
> =A0instruments from which we can get enough information.
>
> Regards,
> Satoru
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
