From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2 5/5] net: Add Open vSwitch kernel components.
Date: Tue, 22 Nov 2011 09:03:15 -0800
Message-ID: <CAEP_g=_pfqgzY3qNzZT6R-jE3nMJOs5nStx664cCX8A5K9Cwrw@mail.gmail.com>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
 <1321911029-20707-6-git-send-email-jesse@nicira.com> <20111121162735.1dfe4cc4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dev@openvswitch.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:58279 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753715Ab1KVRDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 12:03:37 -0500
Received: by ghrr1 with SMTP id r1so377771ghr.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 09:03:37 -0800 (PST)
In-Reply-To: <20111121162735.1dfe4cc4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2011 at 4:27 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> One more comment...
>
> Shouldn't this device be using netdev_increment_features() like bridging and bonding
> to have the features of the pseudo device reflect those of the underlying hardware.
> This would make the device have TSO only if underlying hardware supported it, etc.

It probably should in some form.  One complication is that Open
vSwitch allows multiple internal software devices to be created and
people have found various uses for this capability (different vlans
and namespaces being a few of the more obvious ones but since the
granularity of control is a flow it could represent almost anything).
Traffic can flow between these software devices directly and ideally
shouldn't be limited by the capabilities of the hardware.

Since the current set of offloads is correct, if not always optimal,
the thought was that we do this for now and then improve it over time.
