From: Kartik Chandran <kartik@aristanetworks.com>
Subject: Re: [PATCH net-next] bonding: fix wrong port enabling in 802.3ad
Date: Sun, 23 Oct 2011 08:04:09 -0700
Message-ID: <CAGMsbm4NvX1G6xZyM-cuW_VoJgm=w2o2n3XqzSit0umcGuRqVA@mail.gmail.com>
References: <CAGMsbm4DMPfT6zSZp+fH2XB_gRUHR9FSRDxcwBJVCOhUi4j9AA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sriram Chidambaram <srichida@aristanetworks.com>,
	Hugh Holbrook <holbrook@aristanetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49091 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755336Ab1JWPEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 11:04:10 -0400
Received: by ggnb1 with SMTP id b1so5039911ggn.19
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2011 08:04:09 -0700 (PDT)
In-Reply-To: <CAGMsbm4DMPfT6zSZp+fH2XB_gRUHR9FSRDxcwBJVCOhUi4j9AA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By a strange coincidence, we ran into this exact issue last week while
experimenting with the "standby" state, where we discovered that the
current implementation in bond_3ad does not pay attention to the Mux
SM state when deciding to enable a slave port for transmission, which
causes misbehavior in forwarding on the partner side.

Since the question was raised on the thread about what the 802.3ad
spec says in this respect, we can confidently answer that the spec
clearly mandates that the aggregator should include a port for
transmission only when it goes to DISTRIBUTING ( in independent
control  mode) and COLLECTING+DISTRIBUTING (in coupled mode).

We are testing this extensively right now, so I'm happy to try out
this patch and report back with findings.

-Kartik
