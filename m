From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Mon, 29 Jun 2015 18:06:27 -0700
Message-ID: <CAEP_g=9bAN2X+V6gHXk5uLN0tHt2LyA15Dqr3+C=kQQBZv7mZQ@mail.gmail.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com>
 <558DF24A.1040504@hp.com> <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
 <5591A4DF.4010104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>,
	Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:33984 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbbF3BGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 21:06:47 -0400
Received: by ykfy125 with SMTP id y125so130841231ykf.1
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 18:06:46 -0700 (PDT)
In-Reply-To: <5591A4DF.4010104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2015 at 1:04 PM, Rick Jones <rick.jones2@hp.com> wrote:
> PS  FWIW, if I shift from using just the linux native vxlan to a "mostly
> full" set of OpenStack compute node plumbing - two OVS bridges and a linux
> bridge and associated plumbing with a vxlan tunnel defined in OVS, but
> nothing above the Linux bridge (and no VMs) I see more like 4.9 Gbit/s.  The
> veth pair connecting the linux bridge to the top ovs bridge show rx checksum
> and gro enabled.  the linux bridge itself shows GRO but rx checksum off
> (fixed).  I'm not sure how to go about checking the OVS constructs.

This is because the OVS path won't go through the VXLAN device receive
routines and the code from this patch won't be executed. Your results
make sense then because it is similar to the original no GRO case.

This should hopefully be resolved soon - there are some patches in
progress that will make OVS use the normal tunnel device receive
paths. Once those are in, the performance should be equal in both
cases.
