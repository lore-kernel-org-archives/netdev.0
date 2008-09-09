From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Control Group Classifier
Date: Tue, 9 Sep 2008 02:06:27 +0200
Message-ID: <20080909000627.GF20815@postel.suug.ch>
References: <20080908115101.GE20815@postel.suug.ch> <166fe7950809081428k2e1ba24crd54e66aa027f9998@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Paul Menage <menage@google.com>
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55336 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754606AbYIIAGI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2008 20:06:08 -0400
Content-Disposition: inline
In-Reply-To: <166fe7950809081428k2e1ba24crd54e66aa027f9998@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-09-08 14:28
> Wouldn't this cause a lot of packets (like acks)  to be incorrectly
> classifed to the current tasks cgroup although it may not have
> anything to do with them? That is the reason I chose to put the
> classid into the socket at creation time.

In its current form, it does not work if the packet is rescheduled
or not sent in the context of a process. Such packets simply end
up not being classified at all. In the most common case, the packet
is not queued before it hits the qdisc so this takes away a lot of
complexity and is very fast but should still be sufficient.

Alternatively I also thought about doing a socket lookup in the
classifier (if !skb->sk) and store the classid in the socket. This
would add more flexibility and work for ingress traffic whitout
adding pollution to the sk_buff. It adds a heavy operation to the
classification process though as it would probably require a lock.
