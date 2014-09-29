From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] iproute2: rsvp classifier support for multiple
 actions
Date: Mon, 29 Sep 2014 08:48:39 -0700
Message-ID: <20140929084839.1842edd4@urahara>
References: <1411922993-5828-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:49259 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753165AbaI2Psv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 11:48:51 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so4685158pad.2
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 08:48:51 -0700 (PDT)
In-Reply-To: <1411922993-5828-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 Sep 2014 12:49:53 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> Example setup:
> 
> sudo tc qdisc del dev eth0 root handle 1:0 prio
> sudo tc qdisc add dev eth0 root handle 1:0 prio
> 
> sudo tc filter add dev eth0 pref 10 proto ip parent 1:0 \
> rsvp session 10.0.0.1 ipproto icmp \
> classid 1:1  \
> action police rate 1kbit burst 90k pipe \
> action ok
> 
> tc -s filter show dev eth0 parent 1:0
> 
> filter protocol ip pref 10 rsvp
> filter protocol ip pref 10 rsvp fh 0x0001100a flowid 1:1 session
> 10.0.0.1 ipproto icmp
>         action order 1:  police 0x5 rate 1Kbit burst 23440b mtu 2Kb
> action pipe overhead 0b
> ref 1 bind 1
>         Action statistics:
>         Sent 98000 bytes 1000 pkt (dropped 0, overlimits 761 requeues 0)
>         backlog 0b 0p requeues 0
> 
>         action order 2: gact action pass
>          random type none pass val 0
>          index 2 ref 1 bind 1 installed 60 sec used 3 sec
>         Action statistics:
>         Sent 74578 bytes 761 pkt (dropped 0, overlimits 0 requeues 0)
>         backlog 0b 0p requeues 0
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied both rsvp patches
