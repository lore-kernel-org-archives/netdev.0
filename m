From: "Tom Herbert" <therbert@google.com>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 00:42:03 -0700
Message-ID: <65634d660804250042y5786e305t456f2154a6bcf040@mail.gmail.com>
References: <20080422.205945.229828014.davem@davemloft.net>
	 <87ej8uyjvv.fsf@basil.nowhere.org>
	 <65634d660804242234w66455bedve44801a98e3de9d9@mail.gmail.com>
	 <20080424.233643.250240829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, johnwheffner@gmail.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:20038 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYDYHmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:42:16 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m3P7g40p001416
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 08:42:05 +0100
Received: from py-out-1112.google.com (pyia25.prod.google.com [10.34.253.25])
	by zps78.corp.google.com with ESMTP id m3P7fp3q030913
	for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 00:42:04 -0700
Received: by py-out-1112.google.com with SMTP id a25so4232598pyi.13
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2008 00:42:04 -0700 (PDT)
In-Reply-To: <20080424.233643.250240829.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2008 at 11:36 PM, David Miller <davem@davemloft.net> wrote:
> From: "Tom Herbert" <therbert@google.com>
> Date: Thu, 24 Apr 2008 22:34:50 -0700
>
>
> > Queuing in the host as opposed to in the TX NIC might be beneficial to make
> > work conserving queuing disciplines more effective, since once a packet is
> > queued in the NIC the host can no longer perform any more scheduling on
> > it.    In fact, we have been working on a mechanism to dynamically limit
> > queuing in the NIC (by number of bytes), so that more packets will be queued
> > in host.  This seems to give better results with some of the qdiscs (I can
> > post a patch if there's interest in this).
>
> This work is interesting, but doesn't it make more sense to limit by
> number of packets instead of bytes?
>

If NIC is interrupt driven, enough data must be queued to span
consecutive interrupts.  So for instance if a 10G NIC is generating an
interrupt every 100us, about 125,000 bytes needs to queued at each
interrupt to prevent starvation-- this doesn't translate to a fixed
number of packets.  Limiting by packets seems somewhat ad hoc; if the
limit is to small and the link will be starved, too big and
over-queuing results.

> No intermediate node that I know of drops bytes, they drop packets
> instead :-)
>
