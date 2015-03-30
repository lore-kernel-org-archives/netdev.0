From: Cong Wang <cwang@twopensource.com>
Subject: Re: tc ingress filters not applied
Date: Mon, 30 Mar 2015 10:00:58 -0700
Message-ID: <CAHA+R7O9pfEmGsr_w+srVuOWcA5PTT8pv1Awb_EOOSqxXKVahA@mail.gmail.com>
References: <20150330141523.GQ23551@haze>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:33257 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbC3RA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:00:59 -0400
Received: by iecvj10 with SMTP id vj10so123136740iec.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 10:00:59 -0700 (PDT)
In-Reply-To: <20150330141523.GQ23551@haze>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 7:15 AM, Erik Hugne <erik.hugne@ericsson.com> wrote:
> I'm having troubles with TC policing, the ingress filters does not seem to be
> applied.
>
> node1 ~ # tc qdisc add dev eth0 ingress
> node1 ~ # tc qdisc ls
> qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
> qdisc ingress ffff: dev eth0 parent ffff:fff1 ----------------
> //Test 1: Limit TIPC low importance traffic to 100mbit
> node1 ~ # tc filter add dev eth0 parent ffff: protocol tipc u32 match u8 0 1E at
>  0 police rate 100mbit buffer 10k drop flowid :1
> node1 ~ # tc filter show dev eth0
> node1 ~ #
>
> //Test 2: Limit ICMP to 20kbit
> node1 ~ # tc filter add dev eth0 parent ffff: protocol ip prio 20 u32 match ip p
> rotocol 1 0xff police rate 20kbit buffer 10k drop flowid :2
> node1 ~ # tc filter show dev eth0


tc filter show dev eth0 parent ffff:
